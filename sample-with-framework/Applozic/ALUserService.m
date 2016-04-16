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
#import "ALContactService.h"
#import "ALUserDefaultsHandler.h"

@implementation ALUserService

//1. call this when each message comes

+ (void)processContactFromMessages:(NSArray *) messagesArr withCompletion:(void(^)())completionMark
{
    
    NSMutableOrderedSet* contactIdsArr=[[NSMutableOrderedSet alloc] init ];
   
    NSMutableString * repString=[[NSMutableString alloc] init];
    
    ALContactDBService* dbObj=[[ALContactDBService alloc] init];
    
    for(ALMessage* msg in messagesArr) {
        if(![dbObj getContactByKey:@"userId" value:msg.contactIds]) {
            NSMutableString* appStr=[[NSMutableString alloc] initWithString:msg.contactIds];
            [appStr insertString:@"&userIds=" atIndex:0];
            [contactIdsArr addObject:appStr];
        }
    }
    
    if ([contactIdsArr count] == 0) {
        completionMark();
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
        
        for(id key in userIDs){
            ALContact * createNew=[[ALContact alloc] init];
            createNew.displayName=[userIDs objectForKey:key];
            createNew.userId=key;
            
            ALContactDBService * adding=[[ALContactDBService alloc] init];
            [adding addContact:createNew];
            
        }
        completionMark();
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

+(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark
{
    ALUserClientService * userDetailService = [[ALUserClientService alloc]init];
    
    [userDetailService userDetailServerCall:contactId withCompletion:^(ALUserDetail * userDetail) {
        completionMark(userDetail);

    }];

}

+(void)updateUserDisplayName:(ALContact *)alContact
{
    if(alContact.userId && alContact.displayName)
    {
        ALUserClientService * alUserClientService  = [[ALUserClientService alloc] init];
        [alUserClientService updateUserDisplayName:alContact withCompletion:^(id theJson, NSError *theError) {
            
            if(theError)
            {
                NSLog(@"GETTING ERROR in SEVER CALL FOR DISPLAY NAME");
            }
            else
            {
                ALAPIResponse *apiResponse = [[ALAPIResponse alloc] initWithJSONString:theJson];
            }
            
        }];
    }
    else
    {
         return;
    }
}

+(void)markConversationAsRead:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    
    [ALUserService setUnreadCountZeroForContactId:contactId];

    ALContactDBService * userDBService =[[ALContactDBService alloc] init];
    NSUInteger count = [userDBService markConversationAsDeliveredAndRead:contactId];
    NSLog(@"Found %ld messages for marking as read.", (unsigned long)count);
    
    if(count == 0){
        return;
    }
    ALUserClientService * clientService = [[ALUserClientService alloc] init];
    [clientService markConversationAsReadforContact:contactId withCompletion:^(NSString *response, NSError * error){
                completion(response,error);
    }];
    
}

+(void)setUnreadCountZeroForContactId:(NSString*)contactId{
    
    ALContactService * contactService=[[ALContactService alloc] init];
    ALContact * contact =[contactService loadContactByKey:@"userId" value:contactId];
    contact.unreadCount=[NSNumber numberWithInt:0];
    [contactService updateContact:contact];
    
}
#pragma mark- Mark message READ
//===========================================
+(void)markMessageAsRead:(ALMessage *)alMessage withPairedkeyValue:(NSString *)pairedkeyValue withCompletion:(void (^)(NSString *, NSError *))completion{
    
    
    if(alMessage.groupId != NULL){
        [ALChannelService setUnreadCountZeroForGroupID:alMessage.groupId];
        ALChannelDBService * channelDBService = [[ALChannelDBService alloc] init];
        [channelDBService markConversationAsRead:alMessage.groupId];
    }
    else{
        [ALUserService setUnreadCountZeroForContactId:alMessage.contactIds];
        ALContactDBService * contactDBService=[[ALContactDBService alloc] init];
        [contactDBService markConversationAsDeliveredAndRead:alMessage.contactIds];
        //  TODO: Mark message read&delivered in DB not whole conversation
    }
    


    //Server Call
    ALUserClientService * clientService = [[ALUserClientService alloc] init];
    [clientService markMessageAsReadforPairedMessageKey:pairedkeyValue withCompletion:^(NSString * response, NSError * error) {
        NSLog(@"Response Marking Message :%@",response);
        completion(response,error);
    }];
    
}

//===============================================================================================
#pragma BLOCK USER API
//===============================================================================================

-(void)blockUser:(NSString *)userId withCompletionHandler:(void(^)(NSError *error, BOOL userBlock))completion
{
    [ALUserClientService userBlockServerCall:userId withCompletion:^(NSString *json, NSError *error) {
        
        if(!error)
        {
            ALAPIResponse *forBlockUserResponse = [[ALAPIResponse alloc] initWithJSONString:json];
            if([forBlockUserResponse.status isEqualToString:@"success"])
            {
                ALContactDBService *contactDB = [[ALContactDBService alloc] init];
                [contactDB setBlockUser:userId andBlockedState:YES];
                completion(error, YES);
            }
        }
        
    }];
}

//===============================================================================================
#pragma BLOCK/UNBLOCK USER SYNCHRONIZATION API
//===============================================================================================

-(void)blockUserSync:(NSNumber *)lastSyncTime
{
    [ALUserClientService userBlockSyncServerCall:lastSyncTime withCompletion:^(NSString *json, NSError *error) {
        
        if(!error)
        {
            ALUserBlockResponse * block = [[ALUserBlockResponse alloc] initWithJSONString:(NSString *)json];
            [self updateBlockUserStatusToLocalDB:block];
            [ALUserDefaultsHandler setUserBlockLastTimeStamp:block.generatedAt];
        }
        
    }];
}

-(void)updateBlockUserStatusToLocalDB:(ALUserBlockResponse *)userblock
{
    ALContactDBService *dbService = [ALContactDBService new];
    [dbService blockAllUserInList:userblock.blockedUserList];
    [dbService blockByUserInList:userblock.blockByUserList];
}

//===============================================================================================
#pragma UNBLOCK USER API
//===============================================================================================

-(void)unblockUser:(NSString *)userId withCompletionHandler:(void(^)(NSError *error, BOOL userUnblock))completion
{

    [ALUserClientService userUnblockServerCall:userId withCompletion:^(NSString *json, NSError *error) {

        if(!error)
        {
            ALAPIResponse *forBlockUserResponse = [[ALAPIResponse alloc] initWithJSONString:json];
            if([forBlockUserResponse.status isEqualToString:@"success"])
            {
                ALContactDBService *contactDB = [[ALContactDBService alloc] init];
                [contactDB setBlockUser:userId andBlockedState:NO];
                completion(error, YES);
            }
        }
    }];

}

-(NSMutableArray *)getListOfBlockedUserByCurrentUser
{
    ALContactDBService * dbService = [ALContactDBService new];
    NSMutableArray * blockedUsersList = [dbService getListOfBlockedUsers];
    
    return blockedUsersList;
}

@end
