//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import CVISA
import Foundation

public final class USBInstrument: NIMessageBasedInstrument {
	override init(identifier: String, timeout: TimeInterval) throws {
		guard identifier.hasPrefix("USB"),
					identifier.hasSuffix("::INSTR")
		else {
			throw NIError.invalidResourceName
		}
		try super.init(identifier: identifier, timeout: timeout)
	}
}
