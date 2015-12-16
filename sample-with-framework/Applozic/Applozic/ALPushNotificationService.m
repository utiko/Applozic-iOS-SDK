//
//  ALPushNotificationService.m
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALPushNotificationService.h"
#import "ALMessageDBService.h"


@implementation ALPushNotificationService

+ (NSArray *)ApplozicNotificationTypes
{
    static NSArray *notificationTypes;
    if (!notificationTypes)
    {
        notificationTypes = [[NSArray alloc] initWithObjects:MT_SYNC, MT_MARK_ALL_MESSAGE_AS_READ, MT_DELIVERED,MT_SYNC_PENDING, MT_DELETE_MESSAGE, MT_DELETE_MULTIPLE_MESSAGE, MT_DELETE_MESSAGE_CONTACT, MTEXTER_USER, MT_CONTACT_VERIFIED, MT_CONTACT_VERIFIED, MT_DEVICE_CONTACT_SYNC, MT_EMAIL_VERIFIED,MT_DEVICE_CONTACT_MESSAGE, MT_CANCEL_CALL, MT_MESSAGE, nil];
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
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[NSNumber numberWithBool:updateUI] forKey:@"updateUI"];

        NSString *type = (NSString *)[dictionary valueForKey:@"AL_KEY"];
        NSString *value = (NSString *)[dictionary valueForKey:@"AL_VALUE"];
        
        if ([type isEqualToString:MT_SYNC])
        {
            NSLog(@"pushing to notification center");
            [dict setObject:alertValue forKey:@"alertValue"];

            [[ NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:value userInfo:dict];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"notificationIndividualChat" object:value userInfo:dict];

        } else if ([type isEqualToString: MT_DELIVERED])
        {
            //TODO: move to db layer
            
            NSArray *deliveryParts = [value componentsSeparatedByString:@","];
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService updateMessageDeliveryReport:deliveryParts[0]];
            NSLog(@"delivery report for %@", deliveryParts[0]);
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"deliveryReport" object:deliveryParts[0] userInfo:dictionary];
        } else if ([type isEqualToString: MT_DELETE_MESSAGE_CONTACT])
        {
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService deleteAllMessagesByContact: value];
        } else if ([type isEqualToString: MT_DELETE_MESSAGE])
        {
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService deleteMessageByKey: value];
        }else if ([type isEqualToString:@"APPLOZIC_10"]) {
            NSLog(@"value :: %@", value);
            NSLog(@"type :: %@" ,type);
//            [self.alSyncCallService updateDeliveryStatusForContact: contactId];
//            [self.mqttConversationDelegate updateDeliveryStatusForContact: contactId];
        } else if ([type isEqualToString: @"APPLOZIC_11"]) {
//            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
//            alUserDetail.userId = [theMessageDict objectForKey:@"message"];
//            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
//            alUserDetail.connected = YES;
//            [self.alSyncCallService updateConnectedStatus: alUserDetail];
//            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
            NSLog(@"value :: %@", value);
            NSLog(@"type :: %@" ,type);

        } else if ([type isEqualToString:@"APPLOZIC_12"]) {
//            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
//            
//            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
//            alUserDetail.userId = parts[0];
//            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
//            alUserDetail.connected = NO;
//            
//            [self.alSyncCallService updateConnectedStatus: alUserDetail];
//            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
            NSLog(@"value :: %@", value);
            NSLog(@"type :: %@" ,type);

        }

        
        
        
        
        /*UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
         ChatViewController *chatViewController =
         (ChatViewController*)[navigationController.viewControllers  objectAtIndex:0];
         
         DataModel *dataModel = chatViewController.dataModel;
         
         Message *message = [[Message alloc] init];
         message.date = [NSDate date];
         
         NSString *alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
         
         NSMutableArray *parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
         message.senderName = [parts objectAtIndex:0];
         [parts removeObjectAtIndex:0];
         message.text = [parts componentsJoinedByString:@": "];
         
         int index = [dataModel addMessage:message];
         
         if (updateUI)
         [chatViewController didSaveMessage:message atIndex:index];*/

        return TRUE;
    }
    
    return FALSE;
}

@end
