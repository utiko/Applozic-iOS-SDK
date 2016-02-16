//
//  ALChannelService.m
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALChannelService.h"

@implementation ALChannelService

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
    
    //    callForChannelProxy inserting in DB
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

-(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray withCompletion:(void(^)(NSNumber *channelKey))completion
{
    if(channelName != nil && memberArray.count > 2)
    {
        [ALChannelClientService createChannel: channelName andMembersList: memberArray withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
            if(!error)
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService createChannel: response.alChannel];
                
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

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey
{
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService addMemberToChannel:userId andChannelKey:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService addMemberToChannel:userId andChannelKey:channelKey];
            }
        }];
    }
    else
    {
        return;
    }
    
}

#pragma mark REMOVE MEMBER FROM CHANNEL
//=====================================

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey
{
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService removeMemberFromChannel:userId andChannelKey:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
            }
        }];
    }
    else
    {
        return;
    }
}

#pragma mark DELETE CHANNEL
//=========================

-(void)deleteChannel:(NSNumber *)channelKey
{
    if(channelKey != nil)
    {
        [ALChannelClientService deleteChannel:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService deleteChannel:channelKey];
            }
        }];
    }
    else
    {
        return;
    }
}

-(BOOL)checkAdmin:(NSNumber *)channelKey
{
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *channel = [channelDBService loadChannelByKey:channelKey];
    
    return [channel.adminKey isEqualToString:[ALUserDefaultsHandler getUserId]];
    
}

#pragma mark LEAVE CHANNEL
//=========================

-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId
{
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService leaveChannel:channelKey withUserId:(NSString *)userId andCompletion:^(NSError *error, ALAPIResponse *response) {
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
            }
        }];
    }
    else
    {
        return;
    }
}

#pragma mark RENAME CHANNEL (FROM DEVICE SIDE)
//============================================

-(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName
{
    if(channelKey != nil && newName != nil)
    {
        [ALChannelClientService renameChannel:channelKey andNewName:newName andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService renameChannel:channelKey andNewName:newName];
            }
            
        }];
    }
    else
    {
        return;
    }
    
}

#pragma mark CHANNEL SYNCHRONIZATION
//==================================

+(void)syncCallForChannel:(NSNumber *)updateAt
{
    
    [ALChannelClientService syncCallForChannel:updateAt andCompletion:^(NSError *error, ALChannelSyncResponse *response) {
        
        if([response.status isEqualToString:@"success"])
        {
            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
            [channelDBService processArrayAfterSyncCall:response.alChannelArray];
        }
    }];
    
}

@end
