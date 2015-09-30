//
//  ALPushNotificationService.m
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALPushNotificationService.h"

@implementation ALPushNotificationService

+ (NSArray *)ApplozicNotificationTypes
{
    static NSArray *notificationTypes;
    if (!notificationTypes)
    {
        
        notificationTypes = [[NSArray alloc] initWithObjects:@"MT_SYNC", @"MT_MARK_ALL_MESSAGE_AS_READ", @"MT_DELIVERED", @"MT_SYNC_PENDING", @"MT_DELETE_MESSAGE", @"MT_DELETE_MULTIPLE_MESSAGE", @"MT_DELETE_MESSAGE_CONTACT", @"MTEXTER_USER", @"MT_CONTACT_VERIFIED", @"MT_CONTACT_VERIFIED", @"MT_DEVICE_CONTACT_SYNC", @"MT_EMAIL_VERIFIED", @"MT_DEVICE_CONTACT_MESSAGE", @"MT_CANCEL_CALL", @"MT_MESSAGE", nil];
    }
    return notificationTypes;
}

-(BOOL) isApplozicNotification:(NSDictionary *)dictionary
{
    NSString *type = (NSString *)[dictionary valueForKey:@"AL_TYPE"];
    NSLog(@"notification type %@", type);
    return type != nil && [ALPushNotificationService.ApplozicNotificationTypes containsObject:type];
}

-(BOOL) processPushNotification:(NSDictionary *)dictionary updateUI:(BOOL)updateUI
{
    if ([self isApplozicNotification:dictionary]) {
        //Todo: process it
        NSString *alertValue = [[dictionary valueForKey:@"aps"] valueForKey:@"alert"];
        NSLog(@"Alert: %@", alertValue);
        
        
        NSString *type = (NSString *)[dictionary valueForKey:@"AL_TYPE"];
        NSString *userId = @"applozic";
        
        if ([type isEqualToString:@"MT_SYNC"])
        {
            NSLog(@"comes here");
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:userId userInfo:dictionary];
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
