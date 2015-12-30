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

+(void)getChannelArray:(NSMutableArray *)channelArray
{
    NSMutableArray * memberArray = [NSMutableArray new];
    
    for(ALChannel *channel in channelArray)
    {
        ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
        newChannelUserX.key = channel.key;
        for(NSString *memberName in channel.membersName)
        {
            newChannelUserX.userKey = memberName;
            [memberArray addObject:newChannelUserX];
        }
    }
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    [channelDBService insertChannelUserX:memberArray];
}

+(void)serverCallForChannelCreation:(NSString *)channelId
{
    // POST METHOD
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/create", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userIds=%@",channelId];//check!!! as it is copied
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_CREATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN CHANNEL_CREATION %@", theError);
        }
        else
        {
            //            completionMark(userDetailObject);
        }
    }];
    
}

+(void)serverCallForChannelList:(NSString *)channelId
{
    // GET METHOD
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/list", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userIds=%@",channelId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_CREATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN CHANNEL_CREATION %@", theError);
        }
        else
        {
            //            completionMark(userDetailObject);
        }
    }];
    
}

+(void)serverCallForDeleteChannel:(NSString *)channelId
{
    // GET METHOD
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/delete?id=groupId", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userIds=%@",channelId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_CREATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN CHANNEL_CREATION %@", theError);
        }
        else
        {
            //            completionMark(userDetailObject);
        }
    }];
    
}

+(void)serverCallForRemoveMemberFromChannel:(NSString *)channelId
{
    // GET METHOD
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/remove/member?id=groupId&userId=userId", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userIds=%@",channelId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_CREATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN CHANNEL_CREATION %@", theError);
        }
        else
        {
            //            completionMark(userDetailObject);
        }
    }];
    
}

+(void)serverCallForLeaveMemberFromChannel:(NSString *)channelId
{
    // GET METHOD
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/left?id=groupId", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userIds=%@",channelId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_CREATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN CHANNEL_CREATION %@", theError);
        }
        else
        {
            //            completionMark(userDetailObject);
        }
    }];
    
}


@end
