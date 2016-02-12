//
//  ALChannelClientService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#define CHANNEL_INFO_URL @"/rest/ws/group/info"
#define CHANNEL_SYNC_URL @"/rest/ws/group/list"
#define CREATE_CHANNEL_URL @"/rest/ws/group/create"
#define ADD_MEMBER_TO_CHANNEL_URL @"/rest/ws/group/add/member"
#define REMOVE_MEMBER_FROM_CHANNEL_URL @"/rest/ws/group/remove/member"
#define CHANNEL_NAME_CHANGE_URL @"/rest/ws/group/change/name"

#import "ALChannelClientService.h"

@interface ALChannelClientService ()

@end

@implementation ALChannelClientService

+(void)getChannelInfo:(NSNumber *)channelKey withCompletion:(void(^)(NSMutableArray * arrayList, ALChannel *channel)) completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/info", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@", channelKey];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_INFORMATION" WithCompletionHandler:^(id theJson, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR IN CHANNEL_INFORMATION SERVER CALL REQUEST %@", error);
        }
        else
        {
//            NSLog(@"x=x=x==x=x=x==x  JSON ALCHANNEL CLIENT SERVICE CLASS : :%@  =x=x==x", theJson);
            
            //TODO:::FIX IT
            ALChannelFeed *channelFeed = [[ALChannelFeed alloc] initWithJSONString:theJson];
            
            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
            [channelDBService insertChannel:channelFeed.channelFeedsList];
            
            ALChannel *alChannel = [channelFeed.channelFeedsList objectAtIndex:0];
            
            NSMutableArray * memberArray = [NSMutableArray new];
            
            for(ALChannel *channel in channelFeed.channelFeedsList)
            {
                for(NSString *memberName in channel.membersName)
                {
                    ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
                    newChannelUserX.key = channel.key;
                    newChannelUserX.userKey = memberName;
                    [memberArray addObject:newChannelUserX];
                }
            }
            completion(memberArray, alChannel);
            
            
        }
        
    }];
}

+(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray withCompletion:(void(^)(NSError *error, NSString *json))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, CREATE_CHANNEL_URL];
//    NSString * theUrlString = [NSString stringWithFormat:@"https://staging.applozic.com%@", CREATE_CHANNEL_URL];

    NSMutableDictionary *channelDictionary = [NSMutableDictionary new];
    
    [channelDictionary setObject:channelName forKey:@"groupName"];
    [channelDictionary setObject:memberArray forKey:@"groupMemberList"];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:channelDictionary options:0 error:&error];
    NSString *theParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];

    [ALResponseHandler processRequest:theRequest andTag:@"CREATE_CHANNEL" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError)
        {
            NSLog(@"ERROR IN CREATE_CHANNEL %@", theError);
        }
        else
        {
            NSLog(@"SEVER RESPONSE FROM JSON CREATE_CHANNEL : %@", (NSString *)theJson);
        }
        
        completion(theError, theJson);
        
    }];
    
}

@end
