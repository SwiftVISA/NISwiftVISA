//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/30/20.
//

import CoreSwiftVISA
import CVISA
import Foundation

public class NIMessageBasedInstrument: NIInstrument {
	
}

extension NIMessageBasedInstrument: MessageBasedInstrument {
	public func read(
		until terminator: String,
		strippingTerminator: Bool,
		encoding: String.Encoding,
		chunkSize: Int
	) throws -> String {
		guard let terminatorData = terminator.data(using: encoding) else {
			throw NIError.couldNotDecode
		}
		let data = try readBytes(maxLength: nil,
														 until: terminatorData,
														 strippingTerminator: strippingTerminator,
														 chunkSize: chunkSize)
		
		guard let string = String(data: data, encoding: encoding) else {
			throw NIError.couldNotDecode
		}
		
		return string
	}
	
	public func readBytes(length: Int, chunkSize: Int) throws -> Data {
		var data = Data(capacity: max(length, chunkSize))
		
		repeat {
			var chunk: [ViByte] = []
			var bytesRead: ViUInt32 = 0
			let bytesToRead = ViUInt32(min(chunkSize, length - data.count))
			
			usleep(useconds_t(attributes.operationDelay * 1_000_000.0))
			let status = try NIVISAXPCCommunicator.shared.viRead(_session.viSession,
																													 &chunk,
																													 bytesToRead,
																													 &bytesRead)
			
			guard status == VI_SUCCESS else {
				throw NIError(status)
			}
			
			data.append(Data(chunk))
			
			if bytesRead == 0{
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
	) throws -> Data {
		var data = Data(capacity: max(maxLength ?? chunkSize, chunkSize))
		
		repeat {
			var chunk: [ViByte] = []
			var bytesRead: ViUInt32 = 0
			let bytesToRead = ViUInt32(chunkSize)
			
			usleep(useconds_t(attributes.operationDelay * 1_000_000.0))
			let status = try NIVISAXPCCommunicator.shared.viRead(_session.viSession,
																													 &chunk,
																													 bytesToRead,
																													 &bytesRead)
			
			guard status == VI_SUCCESS else {
				throw NIError(status)
			}
			
			if let maxLength = maxLength {
				if data.count + Int(bytesRead) >= maxLength {
					// Reached max length
					let bytesRemaining = maxLength - data.count
					data.append(Data(chunk[..<bytesRemaining]))
					break
				}
			}
			
			data.append(Data(chunk))
			
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
				to: strippingTerminator ? range.startIndex : range.endIndex)
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
	) throws {
		guard var cString = ((string + (terminator ?? ""))
						.cString(using: encoding)?
						.map { ViByte(bitPattern: $0) })
		else {
			throw NIError.couldNotEncode
		}
		
		
		// The C string inclues a null-terminated byte -- we will discard this
		var returnCount: ViUInt32 = 0
		
		usleep(useconds_t(attributes.operationDelay * 1_000_000.0))
		let status = try NIVISAXPCCommunicator.shared.viWrite(_session.viSession,
																													&cString,
																													UInt32(cString.count) - 1,
																													&returnCount)
		
		guard status == VI_SUCCESS else {
			throw NIError(status)
		}
	}
	
	public func writeBytes(_ data: Data, appending terminator: Data?) throws -> Int {
		let data = data + (terminator ?? Data())
		var message = Array<ViByte>(data)
		var returnCount: ViUInt32 = 0
			
		usleep(useconds_t(attributes.operationDelay * 1_000_000.0))
		let status = try NIVISAXPCCommunicator.shared.viWrite(_session.viSession,
																													&message,
																													ViUInt32(message.count),
																													&returnCount)
		
		guard status == VI_SUCCESS else {
			throw NIError(status)
		}
		
		return Int(returnCount)
	}
}

