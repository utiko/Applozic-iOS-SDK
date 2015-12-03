//
//  ALMQTTConversationService.h
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTSession.h"
#import "ALMessage.h"

@protocol ALMQTTConversationDelegate <NSObject>
-(void) syncCall:(ALMessage *) alMessage;
-(void) delivered:(NSString *) messageKey contactId: (NSString *) contactId;
-(void) updateTypingStatus: (NSString *) applicationKey userId: (NSString *) userId status: (BOOL) status;
-(void) mqttConnectionClosed;
@end

@interface ALMQTTConversationService : NSObject <MQTTSessionDelegate>

+(ALMQTTConversationService *)sharedInstance;

-(void) subscribeToConversation;

-(void) sendTypingStatus:(NSString *) applicationKey userID:(NSString *) userId typing: (BOOL) typing;

@property(nonatomic, weak) id<ALMQTTConversationDelegate>mqttConversationDelegate;

@end
