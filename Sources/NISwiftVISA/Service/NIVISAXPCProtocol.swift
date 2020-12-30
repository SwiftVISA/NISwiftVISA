//
//  NIVISAXPCProtocol.swift
//  NISwiftVISAService
//
//  Created by Connor Barnes on 12/29/20.
//

import Foundation
import CVISA

typealias Reply = (ViStatus) -> Void

@objc protocol NIVISAXPCProtocol {
	func viOpen(_ sesn: ViSession, _ name: ViConstRsrc!, _ mode: ViAccessMode, _ timeout: ViUInt32, _ vi: ViPSession!, reply: @escaping Reply)
	
	func viClose(_ vi: ViObject, reply: @escaping Reply)
	
	func viOpenDefaultRM(_ vi: ViPSession!, reply: @escaping Reply)
}
