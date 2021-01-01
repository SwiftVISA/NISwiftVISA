//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import CVISA

class NIInstrumentManager {
	var session: ViSession
	
	init() throws {
		var session = ViSession()
		let status: ViStatus
		do {
			status = try NIVISAXPCCommunicator.shared.viOpenDefaultRM(&session)
		} catch {
			throw NIError.couldNotConnectToService
		}
		guard status >= VI_SUCCESS else { throw NIError(status) }
		
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
