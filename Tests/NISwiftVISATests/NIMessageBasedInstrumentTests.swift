//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import XCTest
import CVISA
@testable import NISwiftVISA

final class NIMessageBasedInstrumentTests: XCTestCase {
	static var usbInstrument: NIMessageBasedInstrument?
	static let usbInstrumentIdentifier = "USB0::0x2A8D::0x1602::MY59001317::INSTR"
	
	override class func setUp() {
		let im = InstrumentManager.shared
		
		do {
			usbInstrument = try im.niInstrument(withIdentifier: usbInstrumentIdentifier)
				as? NIMessageBasedInstrument
		} catch {
			XCTFail()
		}
	}
	
	func testInstrumentsCreated() {
		XCTAssertNotNil(Self.usbInstrument)
		XCTAssert(Self.usbInstrument is USBInstrument?)
	}
	
	func testRead() {
		
	}
	
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
