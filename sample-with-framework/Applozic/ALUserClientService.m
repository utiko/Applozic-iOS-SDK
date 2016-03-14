//
//  ALUserClientService.m
//  Applozic
//
//  Created by Devashish on 21/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALUserClientService.h"
#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALUserDefaultsHandler.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"

@implementation ALUserClientService

+(void)userLastSeenDetail:(NSNumber *)lastSeenAt withCompletion:(void(^)(ALLastSeenSyncFeed *))completionMark
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/status",KBASE_URL];
    if(!lastSeenAt){
        lastSeenAt = [ALUserDefaultsHandler getLastSyncTime];
        NSLog(@"lastSeenAt is coming as null seeting default vlaue to %@", lastSeenAt);
    }
    NSString * theParamString = [NSString stringWithFormat:@"lastSeenAt=%@",lastSeenAt.stringValue];
    NSLog(@"calling last seen at api for userIds: %@", theParamString);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"USER_LAST_SEEN_NEW" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN LAST SEEN %@", theError);
        }
        else
        {
//            NSLog(@"SEVER RESPONSE FROM JSON : %@", (NSString *)theJson);
            NSNumber * generatedAt =  [theJson  valueForKey:@"generatedAt"];
            [ALUserDefaultsHandler setLastSeenSyncTime:generatedAt];
            ALLastSeenSyncFeed  * responseFeed =  [[ALLastSeenSyncFeed alloc] initWithJSONString:(NSString*)theJson];
            
            completionMark(responseFeed);
        }
        
        
    }];
    
}

-(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/detail",KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userIds=%@",contactId];
    
    NSLog(@"calling last seen at api for userIds: %@", contactId);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"USER_LAST_SEEN" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN LAST SEEN %@", theError);
        }
        else
        {
            //NSLog(@"SEVER RESPONSE FROM JSON : %@", (NSString *)theJson);
            ALUserDetail *userDetailObject = [[ALUserDetail alloc] initWithJSONString:theJson];
             [userDetailObject userDetail];
            completionMark(userDetailObject);
            
        }
        
    }];
    
}

-(void)updateUserDisplayName:(ALContact *)alContact withCompletion:(void(^)(id theJson, NSError *theError))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/name", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"userId=%@&displayName=%@", alContact.userId, alContact.displayName];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"USER_DISPLAY_NAME_UPDATE" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError)
        {
            completion(nil,theError);
            return ;
        }
        else
        {
            NSLog(@"Response of USER_DISPLAY_NAME_UPDATE : %@", (NSString *)theJson);
            completion((NSString *)theJson, nil);
        }
        
    }];
    
}

-(void)markConversationAsReadforContact:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/message/read/conversation",KBASE_URL];
    NSString * theParamString;
    theParamString = [NSString stringWithFormat:@"userId=%@",contactId];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"MARK_CONVERSATION_AS_READ" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            completion(nil,theError);
            NSLog(@"theError");
            return ;
        }else{
            //read sucessfull
            NSLog(@"sucessfully marked read !");
        }
        NSLog(@"Response: %@", (NSString *)theJson);
        completion((NSString *)theJson,nil);
    }];
}

+(void)userBlockServerCall:(NSString *)userId withCompletion:(void (^)(NSString *json, NSError *error))completion
{    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/block",KBASE_URL];
    NSString * theParamString;
    theParamString = [NSString stringWithFormat:@"userId=%@",userId];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"USER_BLOCKED" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSLog(@"USER_BLOCKED RESPONSE JSON: %@", (NSString *)theJson);
        if (theError)
        {
            NSLog(@"theError");
        }
        else
        {
            NSLog(@" %@ SUCCESSFULLY BLOCKED", userId);
            completion((NSString *)theJson, nil);
        }
        
        
    }];
}

+(void)userBlockSyncServerCall:(NSNumber *)lastSyncTime withCompletion:(void (^)(NSString *json, NSError *error))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/blocked/sync",KBASE_URL];
    NSString * theParamString;
    theParamString = [NSString stringWithFormat:@"lastSyncTime=%@",lastSyncTime];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"USER_BLOCK_SYNC" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSLog(@"USER_BLOCKED SYNC RESPONSE JSON: %@", (NSString *)theJson);
        if (theError)
        {
            NSLog(@"theError");
        }
        else
        {
            completion((NSString *)theJson, nil);
        }
        
    }];
}

@end
