//
//  MachService.m
//  
//
//  Created by Connor Barnes on 12/30/20.
//

#import "MachService.h"

@implementation MachService

+ (NSData *_Nullable) sendRequestToRemoteWithName:(NSString *)remoteName messageID:(SInt32)messageID data:(NSData *)data sendTimeout:(CFTimeInterval)sendTimeout returnCode:(SInt32 *_Nonnull)returnCode
{
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
	
	*returnCode = result;
	
	CFRelease(rawData);
	CFRelease(remote);
	CFRetain(rawReturnData);
	
	if (result == kCFMessagePortSuccess && rawReturnData != NULL) {
		return (__bridge NSData * _Nullable) rawReturnData;
	} else {
		return nil;
	}
}

@end
