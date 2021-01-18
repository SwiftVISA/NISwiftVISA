//
//  NIInstrument.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import Foundation

/// An instrument managed by the NI-VISA backend.
public class NIInstrument {
	/// The instrument's session.
	var _session: NISession
	
	public var attributes = MessageBasedInstrumentAttributes()
	/// Creates an instrument from the given identifier and the maximum timout value.
	/// - Parameters:
	///   - identifier: The VISA resource identifier.
	///   - timeout: The maximum amount of time to try to connect to the instrument before failing.
	/// - Throws: If the instrument could not be created.
	required init(identifier: String, timeout: TimeInterval) throws {
		// TODO: Set the instrument timeout
		_session = try .init(identifier: identifier, timeout: timeout)
	}
}

extension NIInstrument: Instrument {
	public var session: Session {
		return _session
	}
}

extension InstrumentManager {
	/// A type contining the VISA identifier prefix and suffix.
	private struct Identifier: Hashable {
		/// The prefix of the identifier.
		var prefix: String
		/// The suffix of the identifier.
		var suffix: String
	}
	/// A dictionary mapping resource identifiers to insturment type.
	private static let classMapping: [Identifier : NIInstrument.Type] = [
		// The commented out lines represent instruments that are not *yet* supported
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
	/// Returns the type of instrument from the instrument's VISA identifier.
	/// - Parameter identifier: The VISA resource identifier.
	/// - Throws: If the insturment class could not be determined or is not supported.
	/// - Returns: The type of instrument.
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
	/// Creates an instrument using the NI-VISA backend.
	/// - Parameters:
	///   - identifier: The VISA resource name.
	///   - timeout: The maximum amount of time (in seconds) to try to create the instrument before failing.
	/// - Throws: If the instrument could not be created.
	/// - Returns: The instrument.
	public func niInstrument(
		withIdentifier identifier: String,
		timeout: TimeInterval? = nil
	) throws -> NIInstrument {
		let InstrumentClass = try Self.instrumentClass(forNIIdentifier: identifier)
		
		return try InstrumentClass.init(identifier: identifier,
																		timeout: timeout ?? connectionTimeout)
	}
}

