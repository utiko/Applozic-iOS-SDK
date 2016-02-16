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
#define DELETE_CHANNEL_URL @"/rest/ws/group/delete"
#define LEFT_CHANNEL_URL @"/rest/ws/group/left"
#define ADD_MEMBER_TO_CHANNEL_URL @"/rest/ws/group/add/member"
#define REMOVE_MEMBER_FROM_CHANNEL_URL @"/rest/ws/group/remove/member"
#define RENAME_CHANNEL_URL @"/rest/ws/group/change/name"

#import "ALChannelClientService.h"

@interface ALChannelClientService ()

@end

@implementation ALChannelClientService

+(void)getChannelInfo:(NSNumber *)channelKey withCompletion:(void(^)(NSError *error, ALChannel *channel)) completion
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
            NSLog(@"x=x=x==x=x=x==x  JSON ALCHANNEL CLIENT SERVICE CLASS : :%@  =x=x==x", theJson);
            ALChannelCreateResponse *response = [[ALChannelCreateResponse alloc] initWithJSONString:theJson];
            completion(error, response.alChannel);
        }
        
    }];
}

+(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray withCompletion:(void(^)(NSError *error, ALChannelCreateResponse *response))completion
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
    NSLog(@"PARAm STRINg %@", theParamString);

    [ALResponseHandler processRequest:theRequest andTag:@"CREATE_CHANNEL" WithCompletionHandler:^(id theJson, NSError *theError) {

        ALChannelCreateResponse *response = nil;
        
        if (theError)
        {
            NSLog(@"ERROR IN CREATE_CHANNEL %@", theError);
        }
        else
        {
            NSLog(@"SEVER RESPONSE FROM JSON CREATE_CHANNEL : %@", (NSString *)theJson);
            response = [[ALChannelCreateResponse alloc] initWithJSONString:theJson];
        }
        
        completion(theError, response);
        
    }];
    
}

+(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, ADD_MEMBER_TO_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@", channelKey, userId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"ADD_NEW_MEMBER_TO_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN ADD_NEW_MEMBER_TO_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, REMOVE_MEMBER_FROM_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@", channelKey, userId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"REMOVE_MEMBER_FROM_CHANNEL_URL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN REMOVE_MEMBER_FROM_CHANNEL_URL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)deleteChannel:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, DELETE_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@", channelKey];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"DELETE_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN DELETE_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)leaveChannel:(NSNumber *)channelKey withUserId:(NSString *)userId andCompletion:(void (^)(NSError *, ALAPIResponse *))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, LEFT_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@", channelKey, userId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"LEAVE_FROM_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN LEAVE_FROM_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName ndCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, RENAME_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@", channelKey, newName];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"RENAME_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN RENAME_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}


@end
