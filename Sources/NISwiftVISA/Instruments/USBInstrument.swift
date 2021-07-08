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
	override class func make(identifier: String, timeout: TimeInterval) async throws -> Self {
    guard identifier.hasPrefix("USB"),
          identifier.hasSuffix("::INSTR")
    else {
      throw NIError.invalidResourceName
    }
    
    let session = try await NISession(identifier: identifier, timeout: timeout)
    return .init(session: session)
  }
  
  required init(session: NISession) {
    super.init(session: session)
  }
}
