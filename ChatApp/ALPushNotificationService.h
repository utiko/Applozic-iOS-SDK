//
//  ALPushNotificationService.h
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPLOZIC_PUSH_NOTIFICATIONS @[ @"MT_SYNC", @"MT_MARK_ALL_MESSAGE_AS_READ", @"MT_DELIVERED", @"MT_SYNC_PENDING", @"MT_DELETE_MESSAGE", @"MT_DELETE_MULTIPLE_MESSAGE", @"MT_DELETE_MESSAGE_CONTACT", @"MTEXTER_USER", @"MT_CONTACT_VERIFIED", @"MT_CONTACT_VERIFIED", @"MT_DEVICE_CONTACT_SYNC", @"MT_EMAIL_VERIFIED", @"MT_DEVICE_CONTACT_MESSAGE", @"MT_CANCEL_CALL", @"MT_MESSAGE"];

@interface ALPushNotificationService : NSObject

-(BOOL) isApplozicNotification: (NSDictionary *) dictionary;

-(BOOL) processPushNotification: (NSDictionary *) dictionary updateUI: (BOOL) updateUI;

@end
