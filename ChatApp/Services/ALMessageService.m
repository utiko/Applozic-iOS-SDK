//
//  ALMessageService.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessageService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALParsingHandler.h"
#import "ALUtilityClass.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageDBService.h"
#import "ALMessageList.h"

@implementation ALMessageService

+(void) getMessagesListGroupByContactswithCompletion:(void(^)(NSMutableArray * messages, NSError * error)) completion {
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/list",KBASE_URL];
    
    NSString * theParamString = nil;
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"GET MESSAGES GROUP BY CONTACT" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
       
        ALMessageList *messageListResponse=  [[ALMessageList alloc] initWithJSONString:theJson] ;
        
        completion(messageListResponse.messageList,nil);
        
    }];
    
}

+(void)getMessageListForUser:(NSString *)userId startIndex:(NSString *)startIndex pageSize:(NSString *)pageSize endTimeInTimeStamp:(NSString *)endTimeStamp withCompletion:(void (^)(NSMutableArray *, NSError *))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/list",KBASE_URL];
    
    NSString * theParamString = [NSString stringWithFormat:@"userId=%@&startIndex=%@&pageSize=%@&endTime=%@",userId,startIndex,pageSize,endTimeStamp];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"GET MESSAGES LIST FOR USERID" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        ALMessageList *messageListResponse=  [[ALMessageList alloc] initWithJSONString:theJson];
        
        completion(messageListResponse.messageList,nil);
        
    }];
    
}

+(void) sendMessagesForUserInfo:(NSDictionary *)userInfo withCompletion:(void(^)(NSString * message, NSError * error)) completion {
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/send",KBASE_URL];
    
    NSString * theParamString = [ALUtilityClass generateJsonStringFromDictionary:userInfo];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"SEND MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        
        NSString *statusStr = (NSString *)theJson;
        
        completion(statusStr,nil);
        
    }];
    
}

+(void) sendPhotoForUserInfo:(NSDictionary *)userInfo withCompletion:(void(^)(NSString * message, NSError *error)) completion {
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/file/url",KBASE_URL];

    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:nil];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CREATE FILE URL" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        
        NSString *imagePostingURL = (NSString *)theJson;
    
        completion(imagePostingURL,nil);
        
    }];
}


+(void) getLatestMessageForUser:(NSString *)deviceKeyString lastSyncTime:(NSString *)lastSyncTime withCompletion:(void (^)(ALMessageList *, NSError *))completion{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/list",KBASE_URL];
    
    NSString * theParamString = [NSString stringWithFormat:@"startTime=%@",lastSyncTime];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"SYNC LATEST MESSAGE URL" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        NSLog(@"sync feed jason..%@", (NSString *)theJson);
        ALMessageList *messageListResponse=  [[ALMessageList alloc] initWithJSONString:theJson];
        if(messageListResponse.messageList.count >0 ){
             ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
            [dbService addMessageList:messageListResponse.messageList];
        }
        NSLog(@"sync feed ..%@", messageListResponse);
        completion(messageListResponse,nil);
        
    }];
}

+(void )deleteMessage:( NSString * ) keyString withCompletion:(void (^)(NSString *, NSError *))completion{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/delete",KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"key=%@",keyString];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"DELETE_MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        NSLog(@"Response of delete: %@", (NSString *)theJson);
        completion((NSString *)theJson,nil);
        
    }];
}
/*
 
 &requestSource=1"
 +"&suUserKeyString=
 */
+(void)deleteMessageThread:( NSString * ) contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/sms/deleteConversion",KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"contactNumber=%@",contactId];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"DELETE_MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            completion(nil,theError);
            return ;
        }else{
            //delete sucessfull
            ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
            [dbService deleteAllMessagesByContact:contactId];
        }
        NSLog(@"Response of delete: %@", (NSString *)theJson);
        completion((NSString *)theJson,nil);
    }];
}
@end
