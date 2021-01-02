//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/29/20.
//

import Foundation
import CVISA
import MachService
import NISwiftVISAServiceMessages
import CoreSwiftVISA

private final class NIVISAMachCommunicator {
	static var shared: NIVISAMachCommunicator = NIVISAMachCommunicator()
	static let hostName = "com.swiftvisa.NISwiftVISAService"
	
	private init() { }
}

extension Message {
	func send() throws -> ReturnMessage {
		let encoded = try JSONEncoder().encode(self)
		
		var returnCode: Int32 = 0
		
		let returnData = MachService.sendRequestToRemote(withName: NIVISAMachCommunicator.hostName,
																								 messageID: 0,
																								 data: encoded,
																								 sendTimeout: InstrumentManager.shared.connectionTimeout,
																								 returnCode: &returnCode)
		
		guard returnCode == MACH_MSG_SUCCESS,
					let data = returnData else { throw NIError.couldNotDecode }

		return try JSONDecoder().decode(ReturnMessage.self, from: data as Data)
	}
}

extension NIVISAMachCommunicator {
	func viOpen(
		_ sesn: ViSession,
		_ name: ViConstRsrc!,
		_ mode: ViAccessMode,
		_ timeout: ViUInt32,
		_ vi: ViPSession!
	) throws -> ViStatus {
		let message = ViOpenMessage(session: sesn,
																resourceName: String(cString: name!),
																mode: mode,
																timeout: timeout,
																vi: vi.pointee)
		
		let returnData = try Message.viOpenMessage(message).send()
		
		guard case .viOpenMessage(let returnMessage) = returnData.message else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown decoding error"))
		}
		
		vi.pointee = returnMessage.vi
		return returnData.status
	}
	
	func viClose(_ vi: ViObject) throws -> ViStatus {
		let message = ViCloseMessage(vi: vi)
		
		let returnData = try Message.viCloseMessage(message).send()
		
		guard case .viCloseMessage(_) = returnData.message else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown decoding error"))
		}
		
		return returnData.status
	}
	
	func viOpenDefaultRM(_ vi: ViPSession) throws -> ViStatus {
		let message = ViOpenDefaultRMMessage(vi: vi.pointee)
		
		let returnData = try Message.viOpenDefaultRMMessage(message).send()
		
		guard case .viOpenDefaultRMMessage(let returnMessage) = returnData.message else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown decoding error"))
		}
		
		vi.pointee = returnMessage.vi
		
		return returnData.status
	}
	
	func viRead(
		_ vi: ViSession,
		_ buffer: inout [ViByte],
		_ count: ViUInt32,
		_ returnCount: ViPUInt32
	) throws -> ViStatus {
		let message = ViReadMessage(vi: vi, buffer: buffer, count: count, returnCount: returnCount.pointee)
		
		let returnData = try Message.viReadMessage(message).send()
		
		guard case .viReadMessage(let returnMessage) = returnData.message else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown decoding error"))
		}
		
		buffer = returnMessage.buffer
		returnCount.pointee = returnMessage.returnCount
		
		return returnData.status
	}
	
	func viWrite(
		_ vi: ViSession,
		_ buffer: inout [ViByte],
		_ count: ViUInt32,
		_ returnCount: ViPUInt32
	) throws -> ViStatus {
		let message = ViWriteMessage(vi: vi, buffer: buffer, count: count, returnCount: returnCount.pointee)
		
		let returnData = try Message.viWriteMessage(message).send()
		
		guard case .viWriteMessage(let returnMessage) = returnData.message else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown decoding error"))
		}
		
		buffer = returnMessage.buffer
		returnCount.pointee = returnMessage.returnCount
		
		return returnData.status
	}
}
