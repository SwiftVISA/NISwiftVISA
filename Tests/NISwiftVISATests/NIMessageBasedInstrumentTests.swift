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
		let im = InstrumentManager.shared
		im.connectionTimeout = 10.0
		
		do {
			usbInstrument = try im.niInstrument(withIdentifier: usbInstrumentIdentifier)
				as? NIMessageBasedInstrument
		} catch {
			XCTFail()
		}
	}
	/// Tests that the insturments were connected to successfully.
	func testInstrumentsCreated() {
		XCTAssertNotNil(Self.usbInstrument)
		XCTAssert(Self.usbInstrument is USBInstrument?)
	}
	/// Tests reading from the instruments.
	func testRead() {
		let command = "VOLTAGE?"
		
		do {
			_ = try Self.usbInstrument?.query(command, as: Double.self)
		} catch {
			XCTFail()
		}
	}
	/// Tests writing to the instruments.
	func testWrite() {
		let command = "OUTPUT ON"
		
		do {
			try Self.usbInstrument?.write(command)
		} catch {
			XCTFail()
		}
	}
	
	static var allTests = [
		("testRead", testRead),
		("testWrite", testWrite)
	]
}
