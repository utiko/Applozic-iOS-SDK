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
    
    [ALChannelClientService getChannelArray:alChannelFeed.channelFeedsList withCompletion:^(BOOL flag, NSMutableArray *array) {
        
        if(flag)
        {
            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
            [channelDBService insertChannelUserX:array];
        }

     }];
}

@end
