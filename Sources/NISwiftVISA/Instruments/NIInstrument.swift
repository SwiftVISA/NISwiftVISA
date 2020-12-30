//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import Foundation

public class NIInstrument {
	var _session: NISession
	public var attributes = MessageBasedInstrumentAttributes()
	
	init(identifier: String, timeout: TimeInterval) throws {
		_session = try .init(identifier: identifier, timeout: timeout)
	}
}

extension NIInstrument: Instrument {
	public var session: Session {
		return _session
	}
}

