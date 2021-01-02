//
//  File.swift
//  
//
//  Created by Connor Barnes on 1/1/21.
//

import Foundation
import NISwiftVISAServiceMessages

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
		
		connection.interruptionHandler = {
			print("Service interupted.")
		}

		connection.invalidationHandler = {
			print("Service invalidated")
		}
		
		service = connection.synchronousRemoteObjectProxyWithErrorHandler { error in
			print("Error establishing synchronous remote object proxy: \(error)")
		} as? VISAXPCProtocol
	}
	
	func reconnect() {
		connection.invalidate()
		connection = .init(machServiceName: Self.hostName)
		connect()
	}
	
	func assertServiceConnected() throws -> VISAXPCProtocol {
		if service == nil {
			reconnect()
		}
		
		guard let service = service else {
			throw NIError.couldNotConnectToService
		}
		
		return service
	}
}
