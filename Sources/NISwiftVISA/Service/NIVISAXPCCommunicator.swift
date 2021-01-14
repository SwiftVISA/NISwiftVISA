//
//  File.swift
//  
//
//  Created by Connor Barnes on 1/1/21.
//

import Foundation
import NISwiftVISAServiceMessages
import CVISA

final class NIVISAXPCCommunicator {
	static var shared = NIVISAXPCCommunicator()
	static let hostName = "com.swiftvisa.NISwiftVISAService"
	
	var connection: NSXPCConnection
	var service: VISAXPCProtocol?
	
	private init() {
		connection = .init(machServiceName: Self.hostName)
		connect()
	}
	
	private func connect() {
		connection.remoteObjectInterface = NSXPCInterface(with: VISAXPCProtocol.self)
		connection.resume()
		
		connection.interruptionHandler = { [weak self] in
			print("Service interupted.")
			self?.service = nil
		}
		
		connection.invalidationHandler = { [weak self] in
			print("Service invalidated")
			self?.service = nil
		}
		
		service = connection.synchronousRemoteObjectProxyWithErrorHandler { [weak self] error in
			print("Error establishing synchronous remote object proxy: \(error)")
			self?.service = nil
			
		} as? VISAXPCProtocol
	}
	
	func reconnect() {
		connection.invalidate()
		connection = .init(machServiceName: Self.hostName)
		connect()
	}
	
	func assertingServiceConnected(
		perform task: (VISAXPCProtocol, ViStatus) throws -> ViStatus
	) throws {
		guard let service = service else {
			reconnect()
			throw NIError.couldNotConnectToService
		}
		
		let nilStatus: ViStatus = -0x7777
		let status = try task(service, nilStatus)
		
		guard status != nilStatus else { throw NIError.couldNotConnectToService }
	}
}
