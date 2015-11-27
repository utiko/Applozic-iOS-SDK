//
//  ALMQTTConversationService.m
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALMQTTConversationService.h"
#import "MQTTSession.h"
#import "ALUserDefaultsHandler.h"
#import "ALConstant.h"

@implementation ALMQTTConversationService

static MQTTSession *session;

+(ALMQTTConversationService *)sharedInstance
{
    static ALMQTTConversationService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALMQTTConversationService alloc] init];
    });
    return sharedInstance;
}

-(void) createSession {
    if (![ALUserDefaultsHandler isLoggedIn]) {
        return;
    }
    NSLog(@"connecting to mqtt server");
    
    session = [[MQTTSession alloc]initWithClientId:[NSString stringWithFormat:@"%@-%f",
                                                    [ALUserDefaultsHandler getUserKeyString],fmod([[NSDate date] timeIntervalSince1970], 10.0)]];
    //session.protocolLevel = 4;
    session.willFlag = TRUE;
    session.willTopic = @"status";
    session.willMsg = [[NSString stringWithFormat:@"%@,%@", [ALUserDefaultsHandler getUserKeyString], @"0"] dataUsingEncoding:NSUTF8StringEncoding];
    session.willQoS = MQTTQosLevelAtMostOnce;
    [session setDelegate:self];
    NSLog(@"waiting for connect...");
    
    [session connectAndWaitToHost:MQTT_URL port:[MQTT_PORT intValue] usingSSL:NO];
    
    NSLog(@"connected...");
}


/*
 * MQTTSessionManagerDelegate
 */
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    /*
     * MQTTClient: process received message
     */
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"#####MQTT: %@", dataString);
    NSLog(@"#####MQTT: %@", topic);
}

-(void) subscribeToConversation {

    [self createSession];
    if (session.status == MQTTSessionStatusConnected) {
        [session subscribeToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];
    }
    
    NSLog(@"Subscribed.");
}

- (void)session:(MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic {
    NSLog(@"##################MQTT NEW MESSAGE");
}


- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSLog(@"MQTT got new message");
    NSLog(@"data: %@", data);
    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"json: %@",myString);
    NSLog(@"topic: %@", topic);
    
    [self.mqttConversationDelegate syncCall];
}

- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray *)qoss
{
    NSLog(@"subscribed");
}

- (void)connected:(MQTTSession *)session {
    NSLog(@"####delegate callback for connected.");
}

- (void)connectionClosed:(MQTTSession *)session {
    NSLog(@"####disconnect from mqtt");
}

- (void)handleEvent:(MQTTSession *)session
              event:(MQTTSessionEvent)eventCode
              error:(NSError *)error {
    NSLog(@"####inside handleEvent");
}

- (void)received:(MQTTSession *)session type:(int)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    NSLog(@"###MQTTreceived command");
    NSLog(@"####type: %i", type);
    NSLog(@"####data: %@", data);
}


@end
