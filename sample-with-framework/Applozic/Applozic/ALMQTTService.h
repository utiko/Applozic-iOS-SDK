//
//  ALMQTTService.h
//  Applozic
//
//  Created by Applozic Inc on 11/26/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTSession.h"
#import "MQTTSessionManager.h"

@interface ALMQTTService : NSObject <MQTTSessionDelegate>

@property (strong, nonatomic) MQTTSessionManager *manager;

@property (strong, nonatomic) NSDictionary *mqttSettings;


+(ALMQTTService *)sharedInstance;

-(void) connectToApplozic;

-(void) createSession;

-(void) disconnectToApplozic;

-(void) disconnectToApplozic: (NSString *) userKey;

-(void) subscribeToConversation;

@end
