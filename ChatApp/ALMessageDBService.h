//
//  ALMessageDBService.h
//  ChatApp
//
//  Created by Devashish on 21/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALMessagesDelegate <NSObject>

-(void)getMessagesArray:(NSMutableArray*)messagesArray;

@end

@interface ALMessageDBService : NSObject


//Add Message APIS
-(void)getMessages;

//update Message APIS
-(void)updateMessageDeliveryReport:(NSString*) messageKeyString;
-(void)updateMessageSyncStatus:(NSString*) keyString;


//Delete Message APIS

-(void) deleteMessage;
-(void) deleteMessageByKey:(NSString*) keyString;
-(void) deleteAllMessagesByContact: (NSString*) contactId;

//Generic APIS
-(BOOL) isMessageTableEmpty;


@property(nonatomic,weak) id <ALMessagesDelegate>delegate;

@end
