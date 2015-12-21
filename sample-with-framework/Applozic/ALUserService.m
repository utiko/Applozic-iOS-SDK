//
//  ALUserService.m
//  Applozic
//
//  Created by Divjyot Singh on 05/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALUserService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALUtilityClass.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageDBService.h"
#import "ALMessageList.h"
#import "ALMessageClientService.h"
#import "ALMessageService.h"
#import "ALContactDBService.h"
#import "ALMessagesViewController.h"
#import "ALLastSeenSyncFeed.h"
#import "ALUserDefaultsHandler.h"
#import "ALUserClientService.h"
#import "ALUserDetail.h"
#import "ALMessageDBService.h"


@implementation ALUserService


//1. call this when each message comes

+ (void)processContactFromMessages:(NSArray *) messagesArr{
    
    NSMutableOrderedSet* contactIdsArr=[[NSMutableOrderedSet alloc] init ];
   
    NSMutableString * repString=[[NSMutableString alloc] init];
    
    ALContactDBService* dbObj=[[ALContactDBService alloc] init];
    
    for(ALMessage* msg in messagesArr) {
        if(![dbObj getContactByKey:@"userId" value:msg.contactIds]) {
            NSMutableString* appStr=[[NSMutableString alloc] initWithString:msg.contactIds];
            [appStr insertString:@"&userIds=" atIndex:0];
            [contactIdsArr addObject:appStr];
        }
        NSLog(@"contact ID(s) %@",msg.contactIds);
    }
    
    if ([contactIdsArr count] == 0) {
        return;
    };
    
    
    for(NSString* strr in contactIdsArr){
        [repString appendString:strr];
    }
    
    NSLog(@"rep String %@",repString);

//    [ALUserService getUserInfo:repString];
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/v1/info",KBASE_URL];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:repString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"GET ALl DISPLAY NAMES" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            return ;
        }
        NSDictionary* userIDs=[[NSDictionary alloc] initWithDictionary:theJson];
        NSLog(@"userIDs theJSON %@",userIDs);
   
        for(id key in userIDs){
            ALContact * createNew=[[ALContact alloc] init];
            createNew.displayName=[userIDs objectForKey:key];
            createNew.userId=key;
            NSLog(@"DISPLAY NAME %@ and ID %@",[userIDs objectForKey:key],key);
            
            ALContactDBService * adding=[[ALContactDBService alloc] init];
            [adding addContact:createNew];
            
        }

    }];
}

+(void)getLastSeenUpdateForUsers:(NSNumber *)lastSeenAt withCompletion:(void(^)(NSMutableArray *))completionMark
{
    
    [ALUserClientService userLastSeenDetail:lastSeenAt withCompletion:^(ALLastSeenSyncFeed * messageFeed) {
         NSMutableArray* lastSeenUpdateArray=   messageFeed.lastSeenArray;
        ALContactDBService *contactDBService =  [[ALContactDBService alloc]init];
        for ( ALUserDetail * userDetail in lastSeenUpdateArray){
            [ contactDBService updateUserDetail:userDetail];
        }
        completionMark(lastSeenUpdateArray);
    }];
    

}

@end
