//
//  ALChannelService.m
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALChannelService.h"
#import "ALMessageClientService.h"
#import "ALConversationService.h"

@implementation ALChannelService
{
    BOOL isChannelLeaved;
    BOOL isChannelRenamed;
    BOOL isChannelDeleted;
    BOOL isChannelMemberAdded;
    BOOL isChannelMemberRemoved;
}

-(void)callForChannelServiceForDBInsertion:(NSString *)theJson
{
    ALChannelFeed *alChannelFeed = [[ALChannelFeed alloc] initWithJSONString:theJson];
    
    ALChannelDBService *alChannelDBService = [[ALChannelDBService alloc] init];
    [alChannelDBService insertChannel:alChannelFeed.channelFeedsList];
    
    NSMutableArray * memberArray = [NSMutableArray new];
    
    for(ALChannel *channel in alChannelFeed.channelFeedsList)
    {
        for(NSString *memberName in channel.membersName)
        {
            ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
            newChannelUserX.key = channel.key;
            newChannelUserX.userKey = memberName;
            [memberArray addObject:newChannelUserX];
        }
        [alChannelDBService insertChannelUserX:memberArray];
        [memberArray removeAllObjects];
    }
    
    //callForChannelProxy inserting in DB...
    ALConversationService *alConversationService = [[ALConversationService alloc] init];
    [alConversationService addConversations:alChannelFeed.conversationProxyList];
    
}

-(void)getChannelInformation:(NSNumber *)channelKey withCompletion:(void (^)(ALChannel *alChannel3)) completion
{
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *alChannel1 = [channelDBService checkChannelEntity:channelKey];
    
    if(alChannel1)
    {
        completion (alChannel1);
    }
    else
    {
        [ALChannelClientService getChannelInfo:channelKey withCompletion:^(NSError *error, ALChannel *alChannel2) {
            
            if(!error)
            {
                ALChannelDBService *dbService = [[ALChannelDBService alloc] init];
                [dbService createChannel:alChannel2];
            }
            
            completion (alChannel2);
            
        }];
        
    }
    
}

-(BOOL)isChannelLeft:(NSNumber*)groupID
{
    ALChannelDBService *dbSerivce = [[ALChannelDBService alloc] init];
    if([dbSerivce isChannelLeft:groupID])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSString *)getChannelName:(NSNumber *)channelKey
{
    ALChannelDBService *dbSerivce = [[ALChannelDBService alloc] init];
    ALChannel *channel = [dbSerivce loadChannelByKey:channelKey];
    return channel.name;
    
}

-(NSString *)stringFromChannelUserList:(NSNumber *)key
{
    ALChannelDBService *ob = [[ALChannelDBService alloc] init];
    return [ob stringFromChannelUserList: key];
}


//====================================================================================================
#pragma mark CHANNEL API
//====================================================================================================


#pragma mark CREATE CHANNEL
//=========================

-(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray withCompletion:(void(^)(NSNumber *channelKey))completion{
    
    if(channelName != nil && memberArray.count >= 2)
    {
        [ALChannelClientService createChannel: channelName andMembersList: memberArray withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
            if(!error)
            {
                response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService createChannel:response.alChannel];
                completion(response.alChannel.key);
                
            }
        }];
    }
    else
    {
        return;
    }
}

#pragma mark ADD NEW MEMBER TO CHANNEL
//====================================

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error,ALAPIResponse *response))completion
{
    
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService addMemberToChannel:userId andChannelKey:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService addMemberToChannel:userId andChannelKey:channelKey];
                completion(error,response);
            }
        }];
        
    }
    
}

#pragma mark REMOVE MEMBER FROM CHANNEL
//=====================================

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, NSString *response))completion {
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService removeMemberFromChannel:userId andChannelKey:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                isChannelMemberRemoved = YES;
            }
            completion(error,response.status);
        }];
    }
}

#pragma mark DELETE CHANNEL
//=========================

-(BOOL)deleteChannel:(NSNumber *)channelKey
{
    isChannelDeleted = NO;
    if(channelKey != nil)
    {
        [ALChannelClientService deleteChannel:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService deleteChannel:channelKey];
                isChannelDeleted = YES;
            }
        }];
    }
    return isChannelDeleted;
}

-(BOOL)checkAdmin:(NSNumber *)channelKey
{
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *channel = [channelDBService loadChannelByKey:channelKey];
    
    return [channel.adminKey isEqualToString:[ALUserDefaultsHandler getUserId]];
    
}

#pragma mark LEAVE CHANNEL
//=========================

-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId withCompletion:(void(^)(NSError *error))completion
{
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService leaveChannel:channelKey withUserId:(NSString *)userId andCompletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                [channelDBService setLeaveFlagForChannel:channelKey];
                completion(error);
            }
        }];
    }
}

#pragma mark RENAME CHANNEL (FROM DEVICE SIDE)
//============================================

-(BOOL)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName
{
    isChannelRenamed = NO;
    if(channelKey != nil && newName != nil)
    {
        [ALChannelClientService renameChannel:channelKey andNewName:newName andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService renameChannel:channelKey andNewName:newName];
                isChannelRenamed = YES;
            }
        }];
    }
    return isChannelRenamed;
}

#pragma mark CHANNEL SYNCHRONIZATION
//==================================

-(void)syncCallForChannel
{
    NSNumber *updateAt = [ALUserDefaultsHandler getLastSyncChannelTime];
    
    [ALChannelClientService syncCallForChannel:updateAt andCompletion:^(NSError *error, ALChannelSyncResponse *response) {
        
        if([response.status isEqualToString:@"success"])
        {
            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
            [channelDBService processArrayAfterSyncCall:response.alChannelArray];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GroupDetailTableReload" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_CHANNEL_NAME" object:nil];
        }
    }];
    
}

#pragma mark MARK READ FOR GROUP
//==============================

+(void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion{
    
    [ALChannelService setUnreadCountZeroForGroupID:channelKey];
    
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    NSUInteger count = [channelDBService markConversationAsRead:channelKey];
    NSLog(@"Found %ld messages for marking as read.", (unsigned long)count);
    
    if(count == 0){
        return;
    }
    
    ALChannelClientService * clientService = [[ALChannelClientService alloc] init];
    [clientService markConversationAsRead:channelKey withCompletion:^(NSString *response, NSError * error) {
        completion(response,error);
    }];

}

+(void)setUnreadCountZeroForGroupID:(NSNumber*)channelKey{
    
    ALChannelDBService *channelDBService = [ALChannelDBService new];
    [channelDBService  updateUnreadCountChannel:channelKey unreadCount:[NSNumber numberWithInt:0]];
    
    ALChannel * channel = [channelDBService loadChannelByKey:channelKey];
    channel.unreadCount = [NSNumber numberWithInt:0];
}

@end
