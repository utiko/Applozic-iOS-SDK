//
//  ALChannelClientService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannelClientService.h"

@interface ALChannelClientService ()

@end

@implementation ALChannelClientService

+(void)getChannelArray:(NSMutableArray *)channelArray withCompletion:(void(^)(BOOL flag, NSMutableArray *array)) completion;
{
    NSMutableArray * memberArray = [NSMutableArray new];
    
    for(ALChannel *channel in channelArray)
    {
        for(NSString *memberName in channel.membersName)
        {
            ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
            newChannelUserX.key = channel.key;
            newChannelUserX.userKey = memberName;
            [memberArray addObject:newChannelUserX];
        }
    }
    completion(YES, memberArray);

}

+(void)getChannelInfo:(NSNumber *)channelKey withCompletion:(void(^)(NSMutableArray * arrayList, BOOL status, ALChannel *channel)) completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/info", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"key=%@", channelKey];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_INFORMATION" WithCompletionHandler:^(id theJson, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR IN CHANNEL_INFORMATION SERVER CALL REQUEST %@", error);
        }
        else
        {
            ALChannelFeed *channelFeed = [[ALChannelFeed alloc] initWithJSONString:theJson];
            
            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
            [channelDBService insertChannel:channelFeed.channelFeedsList];
            
            ALChannel *alChannel = [channelFeed.channelFeedsList objectAtIndex:0];
            
            [self getChannelArray:channelFeed.channelFeedsList withCompletion:^(BOOL flag, NSMutableArray *array)
             {
                 if(flag)
                 {
                     completion(array, flag, alChannel);
                 }
             }];
        }
        
    }];
}

@end
