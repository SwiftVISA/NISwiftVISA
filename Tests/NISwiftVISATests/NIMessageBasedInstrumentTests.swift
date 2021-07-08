//
//  NIMessageBasedInstrumentTests.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import XCTest
import CVISATypes
@testable import NISwiftVISA

/// Tests for message based insturments managed by the NI-VISA backend.
final class NIMessageBasedInstrumentTests: XCTestCase {
	/// The USB instrument to communicate with.
	static var usbInstrument: NIMessageBasedInstrument?
	/// The VISA resource name of the USB insturment to communicate with.
	static let usbInstrumentIdentifier = "USB0::0x2A8D::0x1602::MY59001317::INSTR"
	
	override class func setUp() {
    unsafeWaitFor {
      let im = InstrumentManager.shared
      im.connectionTimeout = 10.0
      
      do {
        usbInstrument = try await im.niInstrument(withIdentifier: usbInstrumentIdentifier)
        as? NIMessageBasedInstrument
      } catch {
        XCTFail()
      }
    }
	}
	/// Tests that the insturments were connected to successfully.
	func testInstrumentsCreated() {
		XCTAssertNotNil(Self.usbInstrument)
		XCTAssert(Self.usbInstrument is USBInstrument?)
	}
	/// Tests reading from the instruments.
	func testRead() async {
		let command = "VOLTAGE?"
		
		do {
			_ = try await Self.usbInstrument?.query(command, as: Double.self)
		} catch {
			XCTFail()
		}
	}
	/// Tests writing to the instruments.
	func testWrite() async  {
		let command = "OUTPUT ON"
		
		do {
			try await Self.usbInstrument?.write(command)
		} catch {
			XCTFail()
		}
	}
	
	static var allTests = [
		("testRead", testRead),
		("testWrite", testWrite)
	]
}

// MARK: - Unsafe Wait For
func unsafeWaitFor(_ operation: @escaping () async -> ()) {
  let semaphore = DispatchSemaphore(value: 0)
  Task {
    await operation()
    semaphore.signal()
  }
  semaphore.wait()
}
