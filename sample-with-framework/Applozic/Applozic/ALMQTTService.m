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

-(void) connectToApplozic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![ALUserDefaultsHandler isLoggedIn]) {
            return;
        }
        
        if (session == nil || session.status != MQTTSessionStatusConnected) {
            [self createSession];
        }
        
        [session publishAndWaitData:[[NSString stringWithFormat:@"%@,%@", [ALUserDefaultsHandler getUserKeyString], @"1"] dataUsingEncoding:NSUTF8StringEncoding]
                            onTopic:@"status"
                             retain:NO
                                qos:MQTTQosLevelAtMostOnce];
        NSLog(@"Published connected.");
    });
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
                                qos:MQTTQosLevelAtMostOnce];
        [session close];
        NSLog(@"Disconnected from mqtt");
    });
}

- (void)session:(MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic {
    NSLog(@"##################MQTT NEW MESSAGE");
}


- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSLog(@"MQTT got new message");
    NSLog(@"data: %@", data);
    NSLog(@"topic: %@", topic);
}

- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray *)qoss
{
    NSLog(@"subscribed");
}


- (void)connected:(MQTTSession *)session {
    
}

- (void)connectionClosed:(MQTTSession *)session {
    
}

- (void)handleEvent:(MQTTSession *)session
              event:(MQTTSessionEvent)eventCode
              error:(NSError *)error {
}

- (void)received:(MQTTSession *)session type:(int)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
  
}


@end
