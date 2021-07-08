//
//  NIMessageBasedInstrument.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import CVISATypes
import Foundation

/// A message-based instrument managed by the NI-VISA backend.
public class NIMessageBasedInstrument: NIInstrument {
	
}

// MARK: - MessageBasedInstrument
extension NIMessageBasedInstrument: MessageBasedInstrument {
	public func read(
		until terminator: String,
		strippingTerminator: Bool,
		encoding: String.Encoding,
		chunkSize: Int
	) async throws -> String {
		guard let terminatorData = terminator.data(using: encoding) else {
      throw NIError.couldNotDecode
    }
    
    let data = try await readBytes(
      maxLength: nil,
      until: terminatorData,
      strippingTerminator: strippingTerminator,
      chunkSize: chunkSize
    )
    
    guard let string = String(data: data, encoding: encoding) else {
      throw NIError.couldNotDecode
    }
		
		return string
	}
	
	public func readBytes(length: Int, chunkSize: Int) async throws -> Data {
		var data = Data(capacity: max(length, chunkSize))
		
		repeat {
      await Task.sleep(UInt64(attributes.operationDelay * 1_000_000_000))
      
      let bytesToRead = ViUInt32(min(chunkSize, length - data.count))
			var chunk: Data!
			var bytesRead: ViUInt32!
			
			try await NIVISAXPCCommunicator.shared
				.assertingServiceConnected { (service, status) -> ViStatus in
					var status = status
					(status, chunk, bytesRead) = await service.read(vi: _session.viSession, count: bytesToRead)
					return status
				}
			
			data.append(chunk)
			
			if bytesRead == 0 {
				// No more data to read
				return data
			}
		} while data.count < length
		
		return data[..<length]
	}
	
	public func readBytes(
		maxLength: Int?,
		until terminator: Data,
		strippingTerminator: Bool,
		chunkSize: Int
	) async throws -> Data {
		var data = Data(capacity: max(maxLength ?? chunkSize, chunkSize))
		
		repeat {
      await Task.sleep(UInt64(attributes.operationDelay * 1_000_000_000))
      
      let bytesToRead = ViUInt32(chunkSize)
			var chunk: Data!
			var bytesRead: ViUInt32!
			
			try await NIVISAXPCCommunicator.shared
				.assertingServiceConnected() { (service, status) -> ViStatus in
					var status = status
					(status, chunk, bytesRead) = await service.read(vi: _session.viSession, count: bytesToRead)
					return status
				}
			
			if let maxLength = maxLength {
				if data.count + Int(bytesRead) >= maxLength {
					// Reached max length
					let bytesRemaining = maxLength - data.count
					data.append(Data(chunk[..<bytesRemaining]))
					break
				}
			}
			
			data.append(chunk)
			
			if (bytesRead == 0) {
				// No more data to read (even if we aren't at the terminator)
				return data
			}
			// TODO: Don't need to search all of the held data, only need to seach the last chunk and some extra in case the terminator data falls over multiple chunks.
		} while data.range(of: terminator, options: .backwards) == nil
			&& data.count < (maxLength ?? .max)
		
		if let range = data.range(of: terminator, options: .backwards) {
			let distance = data.distance(
				from: data.startIndex,
				to: strippingTerminator ? range.startIndex : range.endIndex
      )
			let endIndex = min(maxLength ?? .max, distance)
			return data[..<endIndex]
		}
		
		if data.count > (maxLength ?? .max) {
			return data[..<maxLength!]
		}
		
		return data
	}
	
	public func write(
		_ string: String,
		appending terminator: String?,
		encoding: String.Encoding
	) async throws -> Int {
		guard let data = string.data(using: encoding) else {
			throw NIError.couldNotEncode
		}
		
    await Task.sleep(UInt64(attributes.operationDelay * 1_000_000_000))
    var returnCount: ViUInt32!
    
    try await NIVISAXPCCommunicator.shared
      .assertingServiceConnected() { (service, status) -> ViStatus in
        var status = status
        (status, returnCount) = await service.write(vi: _session.viSession, data: data)
        return status
      }
    
    return Int(returnCount)
  }
  
	public func writeBytes(_ data: Data, appending terminator: Data?) async throws -> Int {
    await Task.sleep(UInt64(attributes.operationDelay * 1_000_000_000))
    
    let data = data + (terminator ?? Data())
		var returnCount: ViUInt32!
		
		try await NIVISAXPCCommunicator.shared
			.assertingServiceConnected { (service, status) -> ViStatus in
				var status = status
				(status, returnCount) = await service.write(vi: _session.viSession, data: data)
				return status
			}
		
		return Int(returnCount)
	}
}
