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
#import "ALDBHandler.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageClientService.h"

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
//(ALMessage *)userInfo withCompletion:(void(^)(NSString * message, NSError * error)) completion

+(void) sendMessages:(ALMessage *)alMessage withCompletion:(void(^)(NSString * message, NSError * error)) completion {
    
    //DB insert if objectID is null
    DB_Message* dbMessage;
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    NSError *theError=nil;
    [[ NSNotificationCenter defaultCenter] postNotificationName:@"updateConversationTableNotification" object:alMessage userInfo:nil];

    if (alMessage.msgDBObjectId==nil){
        NSLog(@"message not in DB new insertion.");

        dbMessage =[dbService addMessage:alMessage];
    }else{
        NSLog(@"message found in DB just getting it not inserting new one...");
        dbMessage =(DB_Message*)[dbService getMeesageById:alMessage.msgDBObjectId error:&theError];
    }
       //convert to dic
    NSDictionary * userInfo = [alMessage dictionary ];
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/send",KBASE_URL];
    NSString * theParamString = [ALUtilityClass generateJsonStringFromDictionary:userInfo];
   
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"SEND MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        
        NSString *statusStr = (NSString *)theJson;
        //TODO: move to db layer
        NSArray *response = [statusStr componentsSeparatedByString:@","];

        ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
        dbMessage.isSent = [NSNumber numberWithBool:YES];
        dbMessage.keyString = response[0];
        dbMessage.inProgress = [NSNumber numberWithBool:NO];
        dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
        NSString * createdAtFromServer =[NSString stringWithFormat:@"%@",(NSString*)response[1]];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        dbMessage.createdAt = [f numberFromString:createdAtFromServer];
        alMessage.keyString = dbMessage.keyString;
        dbMessage.sentToServer=[NSNumber numberWithBool:YES];
        
        alMessage.keyString = dbMessage.keyString;
        alMessage.sentToServer= dbMessage.sentToServer.boolValue;
        alMessage.inProgress=dbMessage.inProgress.boolValue;
        alMessage.isUploadFailed=dbMessage.isUploadFailed.boolValue;
        alMessage.sent = dbMessage.isSent.boolValue;

        [theDBHandler.managedObjectContext save:nil];
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


+(void) getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void (^)( NSMutableArray *, NSError *))completion{
    @synchronized(self) {
        NSString *lastSyncTime =[ALUserDefaultsHandler
                                 getLastSyncTime ];
        if ( lastSyncTime == NULL ){
            lastSyncTime = @"0";
        }
        NSLog(@"last syncTime in call %@", lastSyncTime);
        NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/sync/messages",KBASE_URL];
    
        NSString * theParamString = [NSString stringWithFormat:@"deviceKeyString=%@&lastSyncTime=%@",deviceKeyString,lastSyncTime];
        
        NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
        
        [ALResponseHandler processRequest:theRequest andTag:@"SYNC LATEST MESSAGE URL" WithCompletionHandler:^(id theJson, NSError *theError) {
            
            if (theError) {
                
                completion(nil,theError);
                
                return ;
            }
            ALSyncMessageFeed *syncResponse =  [[ALSyncMessageFeed alloc] initWithJSONString:theJson];
            NSLog(@"count is: %lu", (unsigned long)syncResponse.messagesList.count);
            if(syncResponse.messagesList.count >0 ){
                ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
                [dbService addMessageList:syncResponse.messagesList];
            }
            [ALUserDefaultsHandler
             setLastSyncTime:syncResponse.lastSyncTime];
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService updateDeliveryReports:syncResponse.messagesList];
        
            completion(syncResponse.messagesList,nil);
            
        }];

    }
    
  }

+(void )deleteMessage:( NSString * ) keyString andContactId:( NSString * )contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/mobicomkit/v1/message/delete",KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"key=%@&to=%@&contactNumber=%@",keyString,contactId,contactId];
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
    NSString * theParamString = [NSString stringWithFormat:@"contactNumber=%@&requestSource=1&suUserKeyString=%@",contactId,[ALUserDefaultsHandler getUserKeyString ]];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"DELETE_MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            completion(nil,theError);
            NSLog(@"theError");
            return ;
        }else{
            //delete sucessfull
            NSLog(@"sucessfully deleted !");
            ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
            [dbService deleteAllMessagesByContact:contactId];
        }
        NSLog(@"Response of delete: %@", (NSString *)theJson);
        completion((NSString *)theJson,nil);
    }];
}


+(void) proessUploadImageForMessage:(ALMessage *)message databaseObj:(DB_FileMetaInfo *)fileMetaInfo uploadURL:(NSString *)uploadURL withdelegate:(id)delegate{
    
   
    NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * timestamp = message.imageFilePath;
    NSString * filePath = [docDirPath stringByAppendingPathComponent:timestamp];
    NSMutableURLRequest * request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //Create boundary, it can be anything
        NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        // post body
        NSMutableData *body = [NSMutableData data];
        //Populate a dictionary with all the regular values you would like to send.
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        // add params (all params are strings)
        for (NSString *param in parameters) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        NSString *FileParamConstant = @"files[]";
        NSData *imageData = [[NSData alloc]initWithContentsOfFile:filePath];
        NSLog(@"%f",imageData.length/1024.0);
        //Assuming data is not nil we add this to the multipart form
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant,message.fileMetas.name] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type:image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the request
        [request setHTTPBody:body];
        // set URL
        [request setURL:[NSURL URLWithString:uploadURL]];
        NSMutableArray * theCurrentConnectionsArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
        NSArray * theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.keyString]];
        
        if( theFiletredArray.count>0 ){
            NSLog(@"upload is already running .....not starting new one ....");
            return;
        }
        ALConnection * connection = [[ALConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES];
        connection.keystring =message.keyString;
        connection.connectionType = @"Image Posting";
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
    
    }
  
}
+(void) processImageDownloadforMessage:(ALMessage *) message withdelegate:(id)delegate{
    NSString * urlString = [NSString stringWithFormat:@"%@/rest/ws/file/%@",KBASE_URL,message.fileMetas.keyString];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:urlString paramString:nil];
    ALConnection * connection = [[ALConnection alloc] initWithRequest:theRequest delegate:delegate startImmediately:YES];
    connection.keystring = message.keyString;
    connection.connectionType = @"Image Downloading";
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
}

+(ALMessage*) processFileUploadSucess: (ALMessage *) message{
    
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    DB_Message *dbMessage =  (DB_Message*)[dbService getMessageByKey:@"keyString" value:message.keyString];
    
    dbMessage.fileMetaInfo.blobKeyString = message.fileMetas.blobKeyString;
    dbMessage.fileMetaInfo.contentType = message.fileMetas.contentType;
    dbMessage.fileMetaInfo.createdAtTime = message.fileMetas.createdAtTime;
    dbMessage.fileMetaInfo.keyString = message.fileMetas.keyString;
    dbMessage.fileMetaInfo.name = message.fileMetas.name;
    dbMessage.fileMetaInfo.size = message.fileMetas.size;
    dbMessage.fileMetaInfo.suUserKeyString = message.fileMetas.suUserKeyString;
    message.fileMetaKeyStrings = @[message.fileMetas.keyString];
    [[ALDBHandler sharedInstance].managedObjectContext save:nil];
    return message;
}

@end
