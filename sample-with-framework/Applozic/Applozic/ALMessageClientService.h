//
//  ALMessageClientService.h
//  ChatApp
//
//  Created by devashish on 02/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALMessageList.h"

@interface ALMessageClientService : NSObject

-(void) updateDeliveryReports:(NSMutableArray *) messages;

-(void) updateDeliveryReport: (NSString *) key userId: (NSString *) userId;

-(void) updateDeliveryReport: (NSString *) key;

-(void) addWelcomeMessage;

-(void) getLatestMessageGroupByContactWithCompletion:(void(^)(ALMessageList * alMessageList, NSError * error)) completion;

-(void) getMessagesListGroupByContactswithCompletion:(void(^)(NSMutableArray * messages, NSError * error)) completion;

-(void) getMessageListForUser: (NSString *)userId startIndex:(NSString *)startIndex pageSize:(NSString *)pageSize endTimeInTimeStamp:(NSNumber *)endTimeStamp withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion;

@end
