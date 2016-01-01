//
//  ALMessageService.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageList.h"
#import "ALMessage.h"
#import "DB_FileMetaInfo.h"
#import "ALUserDetail.h"

@interface ALMessageService : NSObject

+(void) processLatestMessagesGroupByContact;

+(void) getLatestMessageGroupByContactWithCompletion:(void(^)(ALMessageList * alMessageList, NSError * error)) completion;

+(void) getMessagesListGroupByContactswithCompletion:(void(^)(NSMutableArray * moments, NSError * error)) completion;

+(void) getMessageListForUser:(NSString *) userId startIndex:(NSString *) startIndex pageSize:(NSString *)pageSize endTimeInTimeStamp:(NSNumber *) endTimeStamp withCompletion:(void(^)(NSMutableArray * messages, NSError * error, NSMutableArray *userDetailArray)) completion;

+(void) sendMessages:(ALMessage *)message withCompletion:(void(^)(NSString * message, NSError * error)) completion;

+(void) sendPhotoForUserInfo:(NSDictionary *)userInfo withCompletion:(void(^)(NSString * message, NSError *error)) completion;


+(void) getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void(^)(NSMutableArray  * message, NSError *error)) completion;

+(void)proessUploadImageForMessage:(ALMessage *)message databaseObj:(DB_FileMetaInfo *)fileMetaInfo uploadURL:(NSString *)uploadURL withdelegate:(id)delegate;

+(void) processImageDownloadforMessage:(ALMessage *) message withdelegate:(id)delegate;

+(ALMessage*) processFileUploadSucess: (ALMessage *)message;

+(void)deleteMessageThread:( NSString * ) contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void )deleteMessage:( NSString * ) keyString andContactId:( NSString * )contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)markConversationAsRead: (NSString *) contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark;

@end
