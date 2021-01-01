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
	
	required init(identifier: String, timeout: TimeInterval) throws {
		_session = try .init(identifier: identifier, timeout: timeout)
	}
}

extension NIInstrument: Instrument {
	public var session: Session {
		return _session
	}
}

extension InstrumentManager {
	private struct Identifier: Hashable {
		var prefix: String
		var suffix: String
	}
	
	private static let classMapping: [Identifier : NIInstrument.Type] = [
//		Identifier(prefix: "ASRL", suffix: "::INSTR") : SerialInstrument.self,
//		Identifier(prefix: "TCPIP", suffix: "::INSTR") : TCPIPInstrument.self,
//		Identifier(prefix: "TCPIP", suffix: "::SOCKET") : TCPIPSocket.self,
		Identifier(prefix: "USB", suffix: "::INSTR") : USBInstrument.self,
//		Identifier(prefix: "USB", suffix: "::RAW") : USBRaw.self,
//		Identifier(prefix: "GPIB", suffix: "::INSTR") : GPIBInstrument.self,
//		Identifier(prefix: "GPIB", suffix: "::INTFC") : GPIBInterface.self,
//		Identifier(prefix: "FIREWIRE", suffix: "::INSTR") : FirewireInstrument.self,
//		Identifier(prefix: "PXI", suffix: "::INSTR") : PXIInstrument.self,
//		Identifier(prefix: "PXI", suffix: "::MEMACC") : PXIMemory.self,
//		Identifier(prefix: "VXI", suffix: "::INSTR") : VXIInstrument.self,
//		Identifier(prefix: "VXI", suffix: "::MEMACC") : VXIMemory.self,
//		Identifier(prefix: "VXI", suffix: "::BACKPLANE") : VXIBackplane.self
	]
	
	private static func instrumentClass(
		forNIIdentifier identifier: String
	) throws -> NIInstrument.Type {
		// Find the first (there should only be one) class mapping that has the given prefix and suffix.
		guard let type = classMapping.first(where: { (key, value) -> Bool in
			identifier.hasPrefix(key.prefix) && identifier.hasSuffix(key.suffix)
		})?.value
		else { throw NIError.invalidInstrumentIdentifier }
		
		return type
	}
	
	public func niInstrument(
		withIdentifier identifier: String,
		timeout: TimeInterval? = nil
	) throws -> NIInstrument {
		let InstrumentClass = try Self.instrumentClass(forNIIdentifier: identifier)
		
		return try InstrumentClass.init(identifier: identifier,
																		timeout: timeout ?? connectionTimeout)
	}
}

