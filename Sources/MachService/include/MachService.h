//
//  MachService.h
//  
//
//  Created by Connor Barnes on 12/30/20.
//

#ifndef MachService_h
#define MachService_h

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

@interface MachService : NSObject

+ (NSData *_Nullable) sendRequestToRemoteWithName:(NSString *_Nonnull)remoteName messageID:(SInt32)messageID data:(NSData *_Nonnull)data sendTimeout:(CFTimeInterval)sendTimeout returnCode:(SInt32 *_Nonnull)returnCode;

@end

#endif /* MachService_h */
