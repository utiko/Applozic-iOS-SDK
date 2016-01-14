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
#import "ALMessage.h"
#import "ALMessageDBService.h"
#import "ALUserDetail.h"
#import "ALPushAssist.h"


@implementation ALMQTTConversationService

static MQTTSession *session;

/*
 MESSAGE_RECEIVED("APPLOZIC_01"), MESSAGE_SENT("APPLOZIC_02"),
 MESSAGE_SENT_UPDATE("APPLOZIC_03"), MESSAGE_DELIVERED("APPLOZIC_04"),
 MESSAGE_DELETED("APPLOZIC_05"), CONVERSATION_DELETED("APPLOZIC_06"),
 MESSAGE_READ("APPLOZIC_07"), MESSAGE_DELIVERED_AND_READ("APPLOZIC_08"),
 CONVERSATION_READ("APPLOZIC_09"), CONVERSATION_DELIVERED_AND_READ("APPLOZIC_10"),
 USER_CONNECTED("APPLOZIC_11"), USER_DISCONNECTED("APPLOZIC_12"),
 GROUP_DELETED("APPLOZIC_13"), GROUP_LEFT("APPLOZIC_14");
 */

+(ALMQTTConversationService *)sharedInstance
{
    static ALMQTTConversationService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALMQTTConversationService alloc] init];
        sharedInstance.alSyncCallService = [[ALSyncCallService alloc] init];
    });
    return sharedInstance;
}

-(void) subscribeToConversation {
    @try {
        if (![ALUserDefaultsHandler isLoggedIn]) {
            return;
        }
        NSLog(@"connecting to mqtt server");
        
        session = [[MQTTSession alloc]initWithClientId:[NSString stringWithFormat:@"%@-%f",
                                                        [ALUserDefaultsHandler getUserKeyString],fmod([[NSDate date] timeIntervalSince1970], 10.0)]];
        session.willFlag = TRUE;
        session.willTopic = @"status";
        session.willMsg = [[NSString stringWithFormat:@"%@,%@", [ALUserDefaultsHandler getUserKeyString], @"0"] dataUsingEncoding:NSUTF8StringEncoding];
        session.willQoS = MQTTQosLevelAtMostOnce;
        [session setDelegate:self];
        NSLog(@"waiting for connect...");
        
        [session connectToHost:MQTT_URL port:[MQTT_PORT intValue] withConnectionHandler:^(MQTTSessionEvent event) {
            if (event == MQTTSessionEventConnected) {
                [session publishAndWaitData:[[NSString stringWithFormat:@"%@,%@", [ALUserDefaultsHandler getUserKeyString], @"1"] dataUsingEncoding:NSUTF8StringEncoding]
                                    onTopic:@"status"
                                     retain:NO
                                        qos:MQTTQosLevelAtMostOnce];
                
                NSLog(@"MQTT: Subscribing to conversation topics.");
                [session subscribeToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];
                [session subscribeToTopic:[NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId]] atLevel:MQTTQosLevelAtMostOnce];
            }
        } messageHandler:^(NSData *data, NSString *topic) {
            
        }];
        
        NSLog(@"MQTT: connected...");
        
        /*if (session.status == MQTTSessionStatusConnected) {
         [session subscribeToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];
         }*/

    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
  }



- (void)session:(MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic {
    NSLog(@"MQTT got new message");
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSString *fullMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"MQTT got new message: %@", fullMessage);

    NSError *error = nil;
    NSDictionary *theMessageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *type = [theMessageDict objectForKey:@"type"];
  //  NSString *instantMessageJson = [theMessageDict objectForKey:@"message"];

    NSString *notificationId = (NSString* )[theMessageDict valueForKey:@"id"];

    if( notificationId && [ALUserDefaultsHandler isNotificationProcessd:notificationId] ){
        NSLog(@"notificationId is already processed...%@",notificationId);
        return;
    }
    
    if ([topic hasPrefix:@"typing"]) {
        NSArray *typingParts = [fullMessage componentsSeparatedByString:@","];
        NSString *applicationKey = typingParts[0]; //Note: will get used once we support messaging from one app to another
        NSString *userId = typingParts[1];
        BOOL typingStatus = [typingParts[2] boolValue];
        [self.mqttConversationDelegate updateTypingStatus:applicationKey userId:userId status:typingStatus];
    } else {
        if ([type isEqualToString:@"MESSAGE_DELIVERED"] || [type isEqualToString:@"MESSAGE_DELIVERED_READ"]||[type isEqualToString:@"APPLOZIC_04"]||[type isEqualToString:@"APPLOZIC_08"]) {
            NSArray *deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            [self.alSyncCallService updateMessageDeliveryReport:deliveryParts[0]];
            [self.mqttConversationDelegate delivered: deliveryParts[0] contactId:deliveryParts[1]];
        } else if ([type isEqualToString: @"MESSAGE_RECEIVED"]||[type isEqualToString:@"APPLOZIC_01"]) {

            ALPushAssist* assistant=[[ALPushAssist alloc] init];
            ALMessage *alMessage = [[ALMessage alloc] initWithDictonary:[theMessageDict objectForKey:@"message"]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:alMessage.message forKey:@"alertValue"];
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"updateUI"];
            
            if(!assistant.isChatViewOnTop){
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"updateUI"];

                NSLog(@" our notification called for mqtt....");
                [assistant assist:alMessage.contactIds and:dict ofUser:alMessage.contactIds];
            }
            else{
                [self.alSyncCallService syncCall: alMessage];
                //Todo: split backend logic and ui logic between synccallservice and delegate
                [self.mqttConversationDelegate syncCall: alMessage];
            }
            
           
//            ALMessage *alMessage = [[ALMessage alloc] initWithDictonary:[theMessageDict objectForKey:@"message"]];
//            [self.alSyncCallService syncCall: alMessage];
//            //Todo: split backend logic and ui logic between synccallservice and delegate
//            [self.mqttConversationDelegate syncCall: alMessage];
//            
            
            
        } else if ([type isEqualToString:@"APPLOZIC_10"]) {
            NSString *contactId = [theMessageDict objectForKey:@"message"];
            [self.alSyncCallService updateDeliveryStatusForContact: contactId];
            [self.mqttConversationDelegate updateDeliveryStatusForContact: contactId];
        } else if ([type isEqualToString: @"APPLOZIC_11"]) {
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = [theMessageDict objectForKey:@"message"];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
            alUserDetail.connected = YES;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
        } else if ([type isEqualToString:@"APPLOZIC_12"]) {
            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = parts[0];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
            alUserDetail.connected = NO;
            
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
        }
    }
}

- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray *)qoss
{
    NSLog(@"subscribed");
}

- (void)connected:(MQTTSession *)session {
    
}

- (void)connectionClosed:(MQTTSession *)session {
    NSLog(@"MQTT connection closed");
    [self.mqttConversationDelegate mqttConnectionClosed];

    //Todo: inform controller about connection closed.
}

- (void)handleEvent:(MQTTSession *)session
              event:(MQTTSessionEvent)eventCode
              error:(NSError *)error {
}

- (void)received:(MQTTSession *)session type:(int)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    
}

-(void) sendTypingStatus:(NSString *) applicationKey userID:(NSString *) userId typing: (BOOL) typing;
{
     NSLog(@"Sending typing status %d to: %@", typing, userId);
    NSData* data=[[NSString stringWithFormat:@"%@,%@,%i", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId], typing ? 1 : 0] dataUsingEncoding:NSUTF8StringEncoding];
    [session publishDataAtMostOnce:data onTopic:[NSString stringWithFormat:@"typing-%@-%@", applicationKey, userId]];
}

-(void) unsubscribeToConversation {
    NSString *userKey = [ALUserDefaultsHandler getUserKeyString];
    [self unsubscribeToConversation: userKey];
}

-(void) unsubscribeToConversation: (NSString *) userKey {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (session == nil) {
            return;
        }
        [session publishAndWaitData:[[NSString stringWithFormat:@"%@,%@", userKey, @"0"] dataUsingEncoding:NSUTF8StringEncoding]
                            onTopic:@"status"
                             retain:NO
                                qos:MQTTQosLevelAtMostOnce];
        [session unsubscribeTopic:[ALUserDefaultsHandler getUserKeyString]];
        [session unsubscribeTopic:[NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId]]];
        [session close];
        NSLog(@"Disconnected from mqtt");
    });
}

@end