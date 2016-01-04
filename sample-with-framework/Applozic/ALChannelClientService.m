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

@end
