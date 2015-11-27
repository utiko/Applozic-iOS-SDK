//
//  ALMQTTConversationService.h
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTSession.h"

@protocol ALMQTTConversationDelegate <NSObject>
-(void) syncCall;
@end

@interface ALMQTTConversationService : NSObject <MQTTSessionDelegate>

+(ALMQTTConversationService *)sharedInstance;

-(void) subscribeToConversation;

@property(nonatomic, weak) id<ALMQTTConversationDelegate>mqttConversationDelegate;

@end
