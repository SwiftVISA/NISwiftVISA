//
//  NISession.swift
//  
//
//  Created by Connor Barnes on 12/28/20.
//

import Foundation
import CVISATypes
import CoreSwiftVISA

/// A session with a system NI-VISA instrument.
public class NISession {
	/// The raw NI-VISA session.
	var viSession: ViSession
	/// The NI-VISA resouce name.
	let identifier: String
	/// Creates a session from an NI-VISA session object.
	/// - Parameters:
	///   - identifier: The VISA resource name.
	///   - timeout: The amount of time (in seconds) to try to create the instrument before failing.
	init(identifier: String, timeout: TimeInterval) throws {
		try viSession = Self.rawSession(withIdentifier: identifier, timeout: timeout)
		
		self.identifier = identifier
	}
	
	deinit {
		try? close()
	}
}

// MARK:- Raw Session
extension NISession {
	/// Returns the raw NI-VISA session for the instrument with the given identifier.
	/// - Parameters:
	///   - identifier: The NI-VISA resource name.
	///   - timeout: The amount of time (in seconds) to try to open the instrument before failing.
	/// - Throws: If the instrument could not be found or connected to.
	/// - Returns: The raw NI-VISA session for the given instrument.
	static func rawSession(
		withIdentifier identifier: String,
		timeout: TimeInterval
	) throws -> ViSession {
		let instrumentManagerSession = try InstrumentManager.niInstrumentManager.get().session
		
		var session: ViSession!
		
		try NIVISAXPCCommunicator.shared
			.assertingServiceConnected { (service, status) -> ViStatus in
			var status = status
			
			service.open(session: instrumentManagerSession, resourceName: identifier, mode: ViAccessMode(VI_NULL), timeout: ViUInt32(1_000 * timeout)) { (statusReply, sessionReply) in
				session = sessionReply
				status = statusReply
			}
			
			return status
		}
		
		return session
	}
}

// MARK:- Session
extension NISession: Session {
	public func close() throws {
		try NIVISAXPCCommunicator.shared
			.assertingServiceConnected { (service, status) -> ViStatus in
			var status = status
			
			service.close(vi: viSession) { (statusReply) in
				status = statusReply
			}
			
			return status
		}
	}
	
	public func reconnect(timeout: TimeInterval) throws {
		try close()
		viSession = try Self.rawSession(withIdentifier: identifier, timeout: timeout)
	}
}
