//
//  ALPushNotificationService.h
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define MT_SYNC @"MT_SYNC"
#define MT_MARK_ALL_MESSAGE_AS_READ @"MT_MARK_ALL_MESSAGE_AS_READ"
#define MT_DELIVERED @"MT_DELIVERED"
#define MT_SYNC_PENDING @"MT_SYNC_PENDING"
#define MT_DELETE_MESSAGE @"MT_DELETE_MESSAGE"
#define MT_DELETE_MULTIPLE_MESSAGE @"MT_DELETE_MULTIPLE_MESSAGE"
#define MT_DELETE_MESSAGE_CONTACT @"MT_DELETE_MESSAGE_CONTACT"
#define MTEXTER_USER @"MTEXTER_USER"
#define MT_CONTACT_VERIFIED @"MT_CONTACT_VERIFIED"
#define MT_DEVICE_CONTACT_SYNC @"MT_DEVICE_CONTACT_SYNC"
#define MT_EMAIL_VERIFIED @"MT_EMAIL_VERIFIED"
#define MT_DEVICE_CONTACT_MESSAGE @"MT_DEVICE_CONTACT_MESSAGE"
#define MT_CANCEL_CALL @"MT_CANCEL_CALL"
#define MT_MESSAGE @"MT_MESSAGE"

#import <Foundation/Foundation.h>

@interface ALPushNotificationService : NSObject

-(BOOL) isApplozicNotification: (NSDictionary *) dictionary;

-(BOOL) processPushNotification: (NSDictionary *) dictionary updateUI: (BOOL) updateUI;

@end
