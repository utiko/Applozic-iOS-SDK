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
    }
    [alChannelDBService insertChannelUserX:memberArray];
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
        [ALChannelClientService getChannelInfo:channelKey withCompletion:^(NSMutableArray *array, ALChannel *alChannel2) {
            
            if(array.count)
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService insertChannelUserX:array];
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

-(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray
{
    if(channelName != nil && memberArray.count > 2)
    {
        [ALChannelClientService createChannel: channelName andMembersList: memberArray withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
            if(!error)
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService createChannel: response.alChannel];
                self.channelKey = response.alChannel.key;
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

#pragma mark DELETE CHANNEL (FROM LOCAL DB)
//=========================================

-(void)deleteChannelFromLocalDB:(NSNumber *)channelKey
{
    if(channelKey != nil)
    {
        ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
        [channelDBService deleteChannel:channelKey];
    }
    else
    {
        return;
    }
}

@end
