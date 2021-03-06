//
//  NIInstrumentManager.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import NISwiftVISAServiceMessages
import CVISATypes

/// A class that manages instruments created through NI-VISA.
class NIInstrumentManager {
	/// The raw NI-VISA session of the resource manager.
	var session: ViSession
	/// Creates the default resource manager.
	/// - Throws: If the resource manager could not be created.
	fileprivate init() throws {
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
	
	/// The shared NIInstrumentManager instance.
	static var niInstrumentManager: Result<NIInstrumentManager, NIError> {
		if let manager = _niInstrumentManager {
			return .success(manager)
		} else {
			do {
				let manager = try NIInstrumentManager()
				// Success - save the resource manager so we don't have to create it again
				Self._niInstrumentManager = manager
				return .success(manager)
			} catch {
				return .failure(error as! NIError)
			}
		}
	}
}
