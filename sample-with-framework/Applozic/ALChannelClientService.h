//
//  ALChannelClientService.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  class for server calls

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALChannel.h"
#import "ALChannelUserX.h"
#import "ALChannelDBService.h"
#import "ALChannelFeed.h"
#import "ALChannelCreateResponse.h"
#import "ALChannelSyncResponse.h"

@interface ALChannelClientService : NSObject

+(void)getChannelInfo:(NSNumber *)channelKey withCompletion:(void(^)(NSError *error, ALChannel *channel)) completion;

+(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray withCompletion:(void(^)(NSError *error, ALChannelCreateResponse *response))completion;

+(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

+(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

+(void)deleteChannel:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

+(void)leaveChannel:(NSNumber *)channelKey withUserId:(NSString *)userId andCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;


+(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName andCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

+(void)syncCallForChannel:(NSNumber *)channelKey andCompletion:(void(^)(NSError *error, ALChannelSyncResponse *response))completion;

@end
