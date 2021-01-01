//
//  MachService.m
//  
//
//  Created by Connor Barnes on 12/30/20.
//

#import "MachService.h"

@implementation MachService

+ (SInt32) sendRequestToRemoteWithName:(NSString *)remoteName messageID:(SInt32)messageID data:(NSData *)data sendTimeout:(CFTimeInterval)sendTimeout returnData:(NSData *_Nullable *_Nullable) returnData
{
	@autoreleasepool {
		CFMessagePortRef remote = CFMessagePortCreateRemote(nil, (__bridge CFStringRef) remoteName);
		
		CFDataRef rawReturnData = NULL;
		CFDataRef rawData = (__bridge CFDataRef) data;
		
		SInt32 result = CFMessagePortSendRequest(remote,
																						 messageID,
																						 rawData,
																						 sendTimeout,
																						 sendTimeout,
																						 kCFRunLoopDefaultMode,
																						 &rawReturnData);
		
		if (result == kCFMessagePortSuccess && rawReturnData != NULL) {
			*returnData = (__bridge NSData * _Nullable) rawReturnData;
		}
		
		CFRelease(rawData);
		
		return result;
	}
}

@end
