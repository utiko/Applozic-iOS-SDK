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

@end
