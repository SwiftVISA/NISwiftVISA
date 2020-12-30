//
//  MachService.h
//  
//
//  Created by Connor Barnes on 12/29/20.
//

#ifndef File_h
#define File_h

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

@interface MachService : NSObject

+ (SInt32) sendRequestToRemoteWithName:(NSString *_Nonnull)remoteName messageID:(SInt32)messageID data:(NSData *_Nonnull)data sendTimeout:(CFTimeInterval)sendTimeout returnData:(NSData *_Nullable *_Nullable) returnData;

@end

#endif /* File_h */
