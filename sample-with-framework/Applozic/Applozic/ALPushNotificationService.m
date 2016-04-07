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
#import "ALChatViewController.h"
//#import "LaunchChatFromSimpleViewController.h"
#import "ALMessagesViewController.h"
#import "ALPushAssist.h"



@implementation ALPushNotificationService

+ (NSArray *)ApplozicNotificationTypes
{
    static NSArray *notificationTypes;
    if (!notificationTypes)
    {
        notificationTypes = [[NSArray alloc] initWithObjects:MT_SYNC, MT_CONVERSATION_READ, MT_DELIVERED,MT_SYNC_PENDING, MT_DELETE_MESSAGE, MT_DELETE_MULTIPLE_MESSAGE, MT_CONVERSATION_DELETED, MTEXTER_USER, MT_CONTACT_VERIFIED, MT_CONTACT_VERIFIED, MT_DEVICE_CONTACT_SYNC, MT_EMAIL_VERIFIED,MT_DEVICE_CONTACT_MESSAGE, MT_CANCEL_CALL, MT_MESSAGE,MT_MESSAGE_DELIVERED_AND_READ,MT_CONVERSATION_DELIVERED_AND_READ,MT_USER_BLOCK,MT_USER_UNBLOCK,nil];
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
        
        //NSLog(@"Alert: %@", alertValue);
        self.alSyncCallService =  [[ALSyncCallService alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[NSNumber numberWithBool:updateUI] forKey:@"updateUI"];
        
        NSString *type = (NSString *)[dictionary valueForKey:@"AL_KEY"];
        NSString *alValueJson = (NSString *)[dictionary valueForKey:@"AL_VALUE"];
        NSData* data = [alValueJson dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *theMessageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSString *notificationId = (NSString* )[theMessageDict valueForKey:@"id"];
        
        if( notificationId && [ALUserDefaultsHandler isNotificationProcessd:notificationId] ){
            NSLog(@"notificationId is already processed...ALPUSH %@",notificationId);
            return true;
        }
        //TODO : check if notification is alreday received and processed...
        NSString *  notificationMsg = [theMessageDict valueForKey:@"message"];
        
        if ([type isEqualToString:MT_SYNC])
        {
            
            [dict setObject:alertValue forKey:@"alertValue"];
            
            ALPushAssist* assistant=[[ALPushAssist alloc] init];
            
            if(!assistant.isOurViewOnTop){
                [dict setObject:@"apple push notification.." forKey:@"Calledfrom"];
                [assistant assist:notificationMsg and:dict ofUser:notificationMsg];
                
            }else {
                [dict setObject:alertValue forKey:@"alertValue"];
                
                [[ NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:notificationMsg
                                                                   userInfo:dict];
                [[ NSNotificationCenter defaultCenter] postNotificationName:@"notificationIndividualChat" object:notificationMsg userInfo:dict];
            }
        }
        else if ([type isEqualToString:@"MESSAGE_SENT"] || [type isEqualToString:@"APPLOZIC_02"]) {
            
        }
        else if ([type isEqualToString:@"MESSAGE_DELIVERED"] ||[type isEqualToString:MT_DELIVERED])  {
            
            NSArray *deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString * pairedKey = deliveryParts[0];
            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"report_DELIVERED" object:deliveryParts[0] userInfo:dictionary];
        }
        else if ( [type isEqualToString:@"MESSAGE_DELIVERED_READ"] ||[type isEqualToString:@"APPLOZIC_08"] ){
            
            NSArray  * deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString * pairedKey = deliveryParts[0];
            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED_AND_READ];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"report_DELIVERED_READ" object:deliveryParts[0] userInfo:dictionary];
        }
        else if ([type isEqualToString: MT_CONVERSATION_DELETED]){
            
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService deleteAllMessagesByContact:notificationMsg orChannelKey:nil];
        }
        else if ([type isEqualToString: @"APPLOZIC_05"]){
            
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
            [messageDBService deleteMessageByKey: notificationMsg];
        }
        else if ([type isEqualToString:@"APPLOZIC_10"]) {
            
            [self.alSyncCallService updateDeliveryStatusForContact:notificationMsg withStatus:DELIVERED_AND_READ];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"report_CONVERSATION_DELIVERED_READ" object:notificationMsg];
            
        }
        else if ([type isEqualToString: @"APPLOZIC_11"]) {
            
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = notificationMsg;
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
            alUserDetail.connected = YES;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"update_USER_STATUS" object:alUserDetail];
        }
        else if ([type isEqualToString:@"APPLOZIC_12"]) {
            
            NSArray *parts = [notificationMsg componentsSeparatedByString:@","];
            
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = parts[0];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
            alUserDetail.connected = NO;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"update_USER_STATUS" object:alUserDetail];
            
        }
        else if ([type isEqualToString:@"APPLOZIC_15"]) {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService syncCallForChannel];
            // TODO HANDLE
        }
        else if ([type isEqualToString:@"APPLOZIC_06"]) {
            // TODO HANDLE
            // IF CONTACT ID THE DELETE USER
            // IF CHANNEL KEY then DELETE CHANNEL
        }
        else if ([type isEqualToString:@"APPLOZIC_16"]) {
//            NSLog(@"BLOCKED / BLOCKED BY");
            if([self processUserBlockNotification:theMessageDict andUserBlockFlag:YES])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_BLOCK_NOTIFICATION" object:nil];
            }
        }
        else if ([type isEqualToString:@"APPLOZIC_17"]) {
//            NSLog(@"UNBLOCKED / UNBLOCKED BY");
            if([self processUserBlockNotification:theMessageDict andUserBlockFlag:NO])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_UNBLOCK_NOTIFICATION" object:nil];
            }
        }
        
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL)processUserBlockNotification:(NSDictionary *)theMessageDict andUserBlockFlag:(BOOL)flag
{
//    NSLog(@"VALUE_MSG : %@",[theMessageDict valueForKey:@"message"]);
    NSArray *mqttMSGArray = [[theMessageDict valueForKey:@"message"] componentsSeparatedByString:@":"];
    NSString *BlockType = mqttMSGArray[0];
    NSString *userId = mqttMSGArray[1];
    if(![BlockType isEqualToString:@"BLOCKED_BY"] && ![BlockType isEqualToString:@"UNBLOCKED_BY"])
    {
        return NO;
    }
    ALContactDBService *dbService = [ALContactDBService new];
    [dbService setBlockByUser:userId andBlockedByState:flag];
    return  YES;
}


@end
