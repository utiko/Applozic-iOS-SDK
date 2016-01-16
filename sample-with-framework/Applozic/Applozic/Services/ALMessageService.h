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
#import "ALChannelService.h"

@interface ALMessageService : NSObject

+(void) processLatestMessagesGroupByContact;


+(void) getMessageListForUser:(NSString *) userId startIndex:(NSString *) startIndex pageSize:(NSString *)pageSize endTimeInTimeStamp:(NSNumber *) endTimeStamp  andChannelKey:(NSNumber *)channelKey withCompletion:(void(^)(NSMutableArray * messages, NSError * error, NSMutableArray *userDetailArray)) completion;

+(void) sendMessages:(ALMessage *)message withCompletion:(void(^)(NSString * message, NSError * error)) completion;


+(void) getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void(^)(NSMutableArray  * message, NSError *error)) completion;

+(void)proessUploadImageForMessage:(ALMessage *)message databaseObj:(DB_FileMetaInfo *)fileMetaInfo uploadURL:(NSString *)uploadURL withdelegate:(id)delegate;

+(void) processImageDownloadforMessage:(ALMessage *) message withdelegate:(id)delegate;

+(ALMessage*) processFileUploadSucess: (ALMessage *)message;

+(void)deleteMessageThread:( NSString * ) contactId orChannelKey:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion;

+(void )deleteMessage:( NSString * ) keyString andContactId:( NSString * )contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)markConversationAsRead: (NSString *) contactId orChannelKey:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)processPendingMessages;


@end
