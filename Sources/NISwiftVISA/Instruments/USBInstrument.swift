//
//  USBInstrument.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import CVISATypes
import Foundation

/// An instrument connected over USB and managed by the NI-VISA backend.
public final class USBInstrument: NIMessageBasedInstrument {
	/// Creates an instrument with the given VISA resource name and timeout.
	/// - Parameters:
	///   - identifier: The VISA resource name.
	///   - timeout: The amount of time (in seconds) to try to connect to the instrument before failing.
	/// - Throws: If the instrument could not be created.
	required init(identifier: String, timeout: TimeInterval) throws {
		guard identifier.hasPrefix("USB"),
					identifier.hasSuffix("::INSTR")
		else {
			throw NIError.invalidResourceName
		}
		try super.init(identifier: identifier, timeout: timeout)
	}
}
