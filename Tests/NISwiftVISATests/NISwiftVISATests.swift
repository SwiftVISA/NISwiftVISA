import XCTest
import CVISA
@testable import NISwiftVISA

final class NISwiftVISATests: XCTestCase {
	func testNISession() {
		do {
			let identifier = "USB0::0x2A8D::0x1602::MY59001317::INSTR"
			let session = try NISession(identifier: identifier, timeout: 1.0)
			try session.close()
		} catch {
			XCTFail()
		}
	}
	
	static var allTests = [
		("testNISession", testNISession),
	]
}
