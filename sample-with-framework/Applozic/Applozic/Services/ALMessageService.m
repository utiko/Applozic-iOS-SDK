//
//  ALMessageService.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessageService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALUtilityClass.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageDBService.h"
#import "ALMessageList.h"
#import "ALDBHandler.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageClientService.h"
#import "ALSendMessageResponse.h"
#import "ALUserService.h"
#import "ALUserDetail.h"
#import "ALContactDBService.h"

@implementation ALMessageService


+(void) processLatestMessagesGroupByContact {
    
    ALMessageClientService * almessageClientService = [[ALMessageClientService alloc]init];
    
    [ almessageClientService getLatestMessageGroupByContactWithCompletion:^( ALMessageList *alMessageList, NSError *error){
        if(alMessageList){
            ALMessageDBService *alMessageDBService = [[ALMessageDBService alloc] init];
            [alMessageDBService addMessageList:alMessageList.messageList];
            ALContactDBService *alContactDBService = [[ALContactDBService alloc] init];
            [alContactDBService addUserDetails:alMessageList.userDetailsList];
            [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
        }
    }];

}


+(void)getMessageListForUser:(NSString *)userId startIndex:(NSString *)startIndex pageSize:(NSString *)pageSize endTimeInTimeStamp:(NSNumber *)endTimeStamp withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion
{
    
    ALMessageDBService *almessageDBService =  [[ALMessageDBService alloc] init];
    NSMutableArray * messageList = [almessageDBService getMessageListForContactWithCreatedAt:userId withCreatedAt:endTimeStamp];
    //Found Record in DB itself ...if not make call to server
    if(messageList.count > 0 && ![ALUserDefaultsHandler isServerCallDoneForMSGList:userId]){
        NSLog(@"message list is coming from DB %ld", (unsigned long)messageList.count);
        completion(messageList, nil, nil);
        return;
    }else {
        NSLog(@"message list is coming from DB %ld", (unsigned long)messageList.count);
    }
    ALMessageClientService *alMessageClientService =  [[ALMessageClientService alloc ]init ];
    
    [alMessageClientService getMessageListForUser:userId startIndex:startIndex pageSize:pageSize endTimeInTimeStamp:endTimeStamp withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray){

        completion(messages, error,userDetailArray);
    }];
    
}


+(void) sendMessages:(ALMessage *)alMessage withCompletion:(void(^)(NSString * message, NSError * error)) completion {
    
    //DB insert if objectID is null
    DB_Message* dbMessage;
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    NSError *theError=nil;
    [[ NSNotificationCenter defaultCenter] postNotificationName:@"updateConversationTableNotification" object:alMessage userInfo:nil];
    
    if (alMessage.msgDBObjectId==nil){
        NSLog(@"message not in DB new insertion.");
        
        dbMessage = [dbService addMessage:alMessage];
    }else{
        NSLog(@"message found in DB just getting it not inserting new one...");
        dbMessage =(DB_Message*)[dbService getMeesageById:alMessage.msgDBObjectId error:&theError];
    }
    //convert to dic
    NSDictionary * messageDict = [alMessage dictionary ];
    ALMessageClientService * alMessageClientService = [[ALMessageClientService alloc]init];
    [ alMessageClientService sendMessage:messageDict WithCompletionHandler:^(id theJson, NSError *theError) {
        NSString *statusStr=nil;
        if(!theError){
            statusStr = (NSString*)theJson;
            //TODO: move to db layer
            ALSendMessageResponse  *response = [[ALSendMessageResponse alloc] initWithJSONString:statusStr ];
            
            ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
            dbMessage.isSent = [NSNumber numberWithBool:YES];
            dbMessage.key = response.messageKey;
            dbMessage.inProgress = [NSNumber numberWithBool:NO];
            dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
            
            dbMessage.createdAt =response.createdAt;
            alMessage.key = dbMessage.key;
            dbMessage.sentToServer=[NSNumber numberWithBool:YES];
            dbMessage.isRead=[NSNumber numberWithBool:YES];
            
            alMessage.key = dbMessage.key;
            alMessage.sentToServer= dbMessage.sentToServer.boolValue;
            alMessage.inProgress=dbMessage.inProgress.boolValue;
            alMessage.isUploadFailed=dbMessage.isUploadFailed.boolValue;
            alMessage.sent = dbMessage.isSent.boolValue;
            
            [theDBHandler.managedObjectContext save:nil];
        }else{
            NSLog(@" got error while sending messages");
        }
        completion(statusStr,theError);
    }];
    
}



+(void) getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void (^)( NSMutableArray *, NSError *))completion{
    ALMessageClientService * alMessageClientService = [[ALMessageClientService alloc]init];
    [ alMessageClientService getLatestMessageForUser:deviceKeyString withCompletion:^(ALSyncMessageFeed * syncResponse , NSError *error) {
        NSMutableArray *messageArray = nil;
        
        if(!error){
            if (syncResponse.deliveredMessageKeys.count > 0) {
                [ALMessageService updateDeliveredReport: syncResponse.deliveredMessageKeys];
            }
            if(syncResponse.messagesList.count >0 ){
                messageArray = [[NSMutableArray alloc] init];
                ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
                messageArray = [dbService addMessageList:syncResponse.messagesList];
            }
            completion(messageArray,error);
            
            [ALUserDefaultsHandler setLastSyncTime:syncResponse.lastSyncTime];
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService updateDeliveryReports:syncResponse.messagesList];
        }else{
            completion(messageArray,error);
        }
        
    }];
    
    
}


+(void) updateDeliveredReport: (NSArray *) deliveredMessageKeys {
    for (id key in deliveredMessageKeys) {
        ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
        [messageDBService updateMessageDeliveryReport:key];
    }
}

+(void )deleteMessage:( NSString * ) keyString andContactId:( NSString * )contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    
    //db
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    [dbService deleteMessageByKey:keyString];
    
    ALMessageClientService *alMessageClientService =  [[ALMessageClientService alloc]init];
    [alMessageClientService deleteMessage:keyString andContactId:contactId
                           withCompletion:^(NSString * response, NSError *error) {
                               completion(response,error);
                           }];
    
    
}


+(void)deleteMessageThread:( NSString * ) contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    
    
    ALMessageClientService *alMessageClientService =  [[ALMessageClientService alloc]init];
    [alMessageClientService deleteMessageThread:contactId
                                 withCompletion:^(NSString * response, NSError *error) {
                                     if (!error){
                                         //delete sucessfull
                                         NSLog(@"sucessfully deleted !");
                                         ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
                                         [dbService deleteAllMessagesByContact:contactId];
                                     }
                                     completion(response,error);
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
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant,message.fileMeta.name] dataUsingEncoding:NSUTF8StringEncoding]];
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
        NSArray * theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.key]];
        
        if( theFiletredArray.count>0 ){
            NSLog(@"upload is already running .....not starting new one ....");
            return;
        }
        ALConnection * connection = [[ALConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES];
        connection.keystring =message.key;
        connection.connectionType = @"Image Posting";
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
        
    }
    
}


+(void) processImageDownloadforMessage:(ALMessage *) message withdelegate:(id)delegate{
    NSString * urlString = [NSString stringWithFormat:@"%@/rest/ws/aws/file/%@",KBASE_FILE_URL,message.fileMeta.blobKey];
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:urlString paramString:nil];
    ALConnection * connection = [[ALConnection alloc] initWithRequest:theRequest delegate:delegate startImmediately:YES];
    connection.keystring = message.key;
    connection.connectionType = @"Image Downloading";
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
}

+(ALMessage*) processFileUploadSucess: (ALMessage *) message{
    
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    DB_Message *dbMessage =  (DB_Message*)[dbService getMessageByKey:@"key" value:message.key];
    
    dbMessage.fileMetaInfo.blobKeyString = message.fileMeta.blobKey;
    dbMessage.fileMetaInfo.contentType = message.fileMeta.contentType;
    dbMessage.fileMetaInfo.createdAtTime = message.fileMeta.createdAtTime;
    dbMessage.fileMetaInfo.key = message.fileMeta.key;
    dbMessage.fileMetaInfo.name = message.fileMeta.name;
    dbMessage.fileMetaInfo.size = message.fileMeta.size;
    dbMessage.fileMetaInfo.suUserKeyString = message.fileMeta.userKey;
    message.fileMetaKey = message.fileMeta.key;
    [[ALDBHandler sharedInstance].managedObjectContext save:nil];
    return message;
}

+(void)markConversationAsRead: (NSString *) contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    
    NSUInteger count = [dbService markConversationAsRead:contactId];
    NSLog(@"Found %ld messages for marking as read.", (unsigned long)count);

    if(count == 0)
    {
        return;
    }
    ALMessageClientService * alMessageClientService  = [[ALMessageClientService alloc]init];
    [alMessageClientService markConversationAsRead:contactId withCompletion:^(NSString *response, NSError * error) {
        completion(response,error);
    }];
    
}

+(void)processPendingMessages{

    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    NSMutableArray * pendingMessageArray = [dbService getPendingMessages];
    NSLog(@"service called....%lu",pendingMessageArray.count);

    for(ALMessage *msg  in pendingMessageArray ){
        
        if(!msg.fileMeta && !msg.pairedMessageKey){
            NSLog(@" resenidng message ..%@", msg.message);
            [self sendMessages:msg withCompletion:^(NSString *message, NSError *error) {
                if(error){
                    NSLog(@" pending messages not sent.....%@", error);
                }else {
                    NSLog(@" sent sucessfully....maked as delivered...%@", message);
                }
                
            }];
        }else{
            NSLog(@" fileMeta present ... %@" ,msg.fileMeta );
        }
        
    }

}


@end
