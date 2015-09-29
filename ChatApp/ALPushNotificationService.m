//
//  ALPushNotificationService.m
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALPushNotificationService.h"

@implementation ALPushNotificationService

-(BOOL) isApplozicNotification:(NSDictionary *)dictionary
{
    
    //Todo: add a check if it is applozic notification.
    return FALSE;
}

-(BOOL) processPushNotification:(NSDictionary *)dictionary updateUI:(BOOL)updateUI
{
    if ([self isApplozicNotification:dictionary]) {
        //Todo: process it
        NSString *alertValue = [[dictionary valueForKey:@"aps"] valueForKey:@"alert"];
        NSLog(@"Alert: %@", alertValue);
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
