//
//  NIVISAXPCCommunicator.swift
//  
//
//  Created by Connor Barnes on 1/1/21.
//

import Foundation
import NISwiftVISAServiceMessages
import CVISATypes

/// A class responsible for communicating with NISwiftVISAService to have calls to C NI-VISA performed on the framework's behalf.
final class NIVISAXPCCommunicator {
	/// The shared communicator instance.
	static var shared = NIVISAXPCCommunicator()
	/// The mach name of the service.
	static let hostName = "com.swiftvisa.NISwiftVISAService"
	/// The XPC connection to the service.
	var connection: NSXPCConnection
	/// The XPC service.
	var service: VISAXPCProtocol?
	/// Creates a default communicator.
	private init() {
		connection = .init(machServiceName: Self.hostName)
		connect()
	}
	/// Tries to connect to the service.
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
	/// Tries to reconnect to the service.
	func reconnect() {
		connection.invalidate()
		connection = .init(machServiceName: Self.hostName)
		connect()
	}
	/// Performs a task if the service is connected.
	/// - Parameter task: The task to perfom.
	/// - Throws: If the task threw an error or if the service was not connected.
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
