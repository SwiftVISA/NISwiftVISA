//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import NISwiftVISAServiceMessages
import CVISA

class NIInstrumentManager {
	var session: ViSession
	
	init() throws {
		
		var session: ViSession!
		
		try NIVISAXPCCommunicator.shared
			.assertingServiceConnected() { (service: VISAXPCProtocol, status: ViStatus) -> ViStatus in
				var status = status
				
				service.openDefaultRM { (statusReply, sessionReply) in
					status = statusReply
					session = sessionReply
				}
				
				return status
			}
		
		self.session = session
	}
}

extension InstrumentManager {
	private static var _niInstrumentManager: NIInstrumentManager?
	
	static var niInstrumentManager: Result<NIInstrumentManager, NIError> {
		if let manager = _niInstrumentManager {
			return .success(manager)
		} else {
			do {
				let manager = try NIInstrumentManager()
				return .success(manager)
			} catch {
				return .failure(error as! NIError)
			}
		}
	}
}
