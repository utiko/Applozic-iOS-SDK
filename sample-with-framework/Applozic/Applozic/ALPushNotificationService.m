//
//  ALPushNotificationService.m
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALPushNotificationService.h"
#import "ALMessageDBService.h"
#import "ALUserDetail.h"
#import "ALUserDefaultsHandler.h"


@implementation ALPushNotificationService

+ (NSArray *)ApplozicNotificationTypes
{
    static NSArray *notificationTypes;
    if (!notificationTypes)
    {
        notificationTypes = [[NSArray alloc] initWithObjects:MT_SYNC, MT_CONVERSATION_READ, MT_DELIVERED,MT_SYNC_PENDING, MT_DELETE_MESSAGE, MT_DELETE_MULTIPLE_MESSAGE, MT_CONVERSATION_DELETED, MTEXTER_USER, MT_CONTACT_VERIFIED, MT_CONTACT_VERIFIED, MT_DEVICE_CONTACT_SYNC, MT_EMAIL_VERIFIED,MT_DEVICE_CONTACT_MESSAGE, MT_CANCEL_CALL, MT_MESSAGE,MT_MESSAGE_DELIVERED_AND_READ,nil];
    }
    return notificationTypes;
}

-(BOOL) isApplozicNotification:(NSDictionary *)dictionary
{
    NSString *type = (NSString *)[dictionary valueForKey:@"AL_KEY"];
    NSLog(@"notification type %@", type);
    return type != nil && [ALPushNotificationService.ApplozicNotificationTypes containsObject:type];
}

-(BOOL) processPushNotification:(NSDictionary *)dictionary updateUI:(BOOL)updateUI
{
    NSLog(@"update ui: %@", updateUI ? @"Yes": @"No");
    //[dictionary setObject:@"Yes" forKey:@"updateUI"]; // adds @"Bar"
    
    if ([self isApplozicNotification:dictionary]) {
        //Todo: process it
        NSString *alertValue = [[dictionary valueForKey:@"aps"] valueForKey:@"alert"];
        
        NSLog(@"Alert: %@", alertValue);
        self.alSyncCallService =  [[ALSyncCallService alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[NSNumber numberWithBool:updateUI] forKey:@"updateUI"];
        
        NSString *type = (NSString *)[dictionary valueForKey:@"AL_KEY"];
        NSString *alValueJson = (NSString *)[dictionary valueForKey:@"AL_VALUE"];
        NSData* data = [alValueJson dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *theMessageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSString *notificationId = (NSString* )[theMessageDict valueForKey:@"id"];
        if( [ALUserDefaultsHandler isNotificationProcessd:notificationId] ){
            NSLog(@"Id is already processed...%@",notificationId);
            return true;
        }
        //TODO : check if notification is alreday received and processed...
        NSString *  notificationMsg = [theMessageDict valueForKey:@"message"];
        
        if ([type isEqualToString:MT_SYNC])
        {
            NSLog(@"pushing to notification center");
            [dict setObject:alertValue forKey:@"alertValue"];

            [[ NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:notificationMsg
                                                               userInfo:theMessageDict];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"notificationIndividualChat" object:notificationMsg userInfo:theMessageDict];
        }else if ([type isEqualToString:@"MESSAGE_DELIVERED"] || [type isEqualToString:@"MESSAGE_DELIVERED_READ"]||[type isEqualToString:MT_DELIVERED]||[type isEqualToString:@"APPLOZIC_08"])  {
            
            NSArray *deliveryParts = [notificationMsg componentsSeparatedByString:@","];
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService updateMessageDeliveryReport:deliveryParts[0]];
            NSLog(@"delivery report for %@", deliveryParts[0]);
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"deliveryReport" object:deliveryParts[0] userInfo:dictionary];
        }else if ([type isEqualToString: MT_CONVERSATION_DELETED]){
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService deleteAllMessagesByContact:notificationMsg];
        }else if ([type isEqualToString: @"APPLOZIC_05"])
        {
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService deleteMessageByKey: notificationMsg];
        }else if ([type isEqualToString:@"APPLOZIC_10"]) {
            [self.alSyncCallService updateDeliveryStatusForContact: notificationMsg];
            //[self.mqttConversationDelegate updateDeliveryStatusForContact: contactId];
        } else if ([type isEqualToString: @"APPLOZIC_11"]) {
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = notificationMsg;
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
            alUserDetail.connected = YES;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            //[self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
        } else if ([type isEqualToString:@"APPLOZIC_12"]) {
            
            NSArray *parts = [notificationMsg componentsSeparatedByString:@","];
            
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = parts[0];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
            alUserDetail.connected = NO;
            
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            //[self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
            
        }
        return TRUE;
    }
    
    return FALSE;
}

@end
