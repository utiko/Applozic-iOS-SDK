//
//  ALUserClientService.h
//  Applozic
//
//  Created by Devashish on 21/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALLastSeenSyncFeed.h"

@interface ALUserClientService : NSObject

+(void)userLastSeenDetail:(NSNumber *)lastSeenAt withCompletion:(void(^)(ALLastSeenSyncFeed *))completionMark;
@end
