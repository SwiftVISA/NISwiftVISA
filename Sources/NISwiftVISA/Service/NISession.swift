//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/28/20.
//

import Foundation
import CVISA
import CoreSwiftVISA

/// A session with a system NI-VISA instrument.
public class NISession {
	var viSession: ViSession
	let identifier: String
	
	/// Creates a session from an NI-VISA session object.
	/// - Parameter identifier: The VISA resource name.
	init(identifier: String, timeout: TimeInterval) throws {
		try viSession = Self.rawSession(withIdentifier: identifier, timeout: timeout)
		
		self.identifier = identifier
	}
}

extension NISession {
	static func rawSession(
		withIdentifier identifier: String,
		timeout: TimeInterval
	) throws -> ViSession {
		let instrumentManagerSession = try InstrumentManager.niInstrumentManager.get().session
		
		var session = ViSession()
		
		let status = try NIVISAXPCCommunicator.shared.viOpen(
			instrumentManagerSession,
			identifier,
			ViAccessMode(VI_NULL),
			ViUInt32(1_000 * timeout),
			&session)
		
		guard status >= VI_SUCCESS else { throw NIError(status) }
		
		return session
	}
}

extension NISession: Session {
	public func close() throws {
		let status = try NIVISAXPCCommunicator.shared.viClose(viSession)
		guard status >= VI_SUCCESS else { throw NIError(status) }
	}
	
	public func reconnect(timeout: TimeInterval) throws {
		try close()
		viSession = try Self.rawSession(withIdentifier: identifier, timeout: timeout)
	}
}
