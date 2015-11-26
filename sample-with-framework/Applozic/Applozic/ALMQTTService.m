//
//  ALMQTTService.m
//  Applozic
//
//  Created by Applozic Inc on 11/26/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALMQTTService.h"
#import "ALUserDefaultsHandler.h"
#import "MQTTSessionManager.h"
#import "MQTTSession.h"
#import "ALConstant.h"

@implementation ALMQTTService

static MQTTSession *session;

+(ALMQTTService *)sharedInstance
{
    static ALMQTTService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALMQTTService alloc] init];
        // Do any other initialisation stuff here
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
    
    // Set delegate appropriately to receive various events
    // See MQTTSession.h for information on various handlers
    // you can subscribe to.
    [session setDelegate:self];
    NSLog(@"waiting for connect...");
    
    [session connectAndWaitToHost:MQTT_URL port:[MQTT_PORT intValue] usingSSL:NO];
    
    NSLog(@"connected...");
}

-(void) connectToApplozic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![ALUserDefaultsHandler isLoggedIn]) {
            return;
        }
        if (session == nil) {
            [self createSession];
        }
        
        [session publishAndWaitData:[[NSString stringWithFormat:@"%@,%@", [ALUserDefaultsHandler getUserKeyString], @"1"] dataUsingEncoding:NSUTF8StringEncoding]
                            onTopic:@"status"
                             retain:NO
                                qos:MQTTQosLevelAtLeastOnce];
        NSLog(@"Published connected.");

        [self subscribeToConversation];

    });
}

-(void) subscribeToConversation {
    if (session == nil) {
        [self createSession];
    }
    if (session.status == MQTTSessionStatusConnected) {
        [session subscribeAndWaitToTopic:@"status" atLevel:MQTTQosLevelAtMostOnce];
        [session subscribeAndWaitToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];
    }
    
   /* [session subscribeToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];*/
    NSLog(@"Subscribed.");
}

-(void) disconnectToApplozic {
    NSString *userKey = [ALUserDefaultsHandler getUserKeyString];
    [self disconnectToApplozic: userKey];
}

-(void) disconnectToApplozic: (NSString *) userKey {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (session == nil) {
            return;
        }
        [session publishAndWaitData:[[NSString stringWithFormat:@"%@,%@", userKey, @"0"] dataUsingEncoding:NSUTF8StringEncoding]
                            onTopic:@"status"
                             retain:NO
                                qos:MQTTQosLevelAtLeastOnce];
        [session close];
        NSLog(@"Disconnected from mqtt");
    });
}





- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSLog(@"MQTT got new message");
    
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
    NSLog(@"###received command");
    NSLog(@"####type: %i", type);
    NSLog(@"####data: %@", data);
}


@end
