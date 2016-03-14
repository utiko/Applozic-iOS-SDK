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
#import "ALAPIResponse.h"

@interface ALUserService : NSObject

+ (void)processContactFromMessages:(NSArray *) messagesArr;

+(void)getLastSeenUpdateForUsers:(NSNumber *)lastSeenAt withCompletion:(void(^)(NSMutableArray *))completionMark;

+(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark;

+(void)updateUserDisplayName:(ALContact *)alContact;

+(void)markConversationAsRead:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion;

-(void)blockUser:(NSString *)userId;

-(void)blockUserSync:(NSNumber *)lastSyncTime;

-(void)updateBlockUserStatusToLocalDB:(NSMutableArray *)userList;

@end
