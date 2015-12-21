//
//  ALUserService.h
//  Applozic
//
//  Created by Divjyot Singh on 05/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageList.h"
#import "ALMessage.h"
#import "DB_FileMetaInfo.h"
#import "ALLastSeenSyncFeed.h"
#import "ALUserClientService.h"

@interface ALUserService : NSObject

+ (void)processContactFromMessages:(NSArray *) messagesArr;

+(void)getLastSeenUpdateForUsers:(NSNumber *)lastSeenAt withCompletion:(void(^)(NSMutableArray *))completionMark;

@end
