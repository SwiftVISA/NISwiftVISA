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

+ (SInt32) sendRequestToRemoteWithName:(NSString *_Nonnull)remoteName messageID:(SInt32)messageID data:(NSData *_Nonnull)data sendTimeout:(CFTimeInterval)sendTimeout returnData:(NSData *_Nullable *_Nullable) returnData;

@end

#endif /* MachService_h */
