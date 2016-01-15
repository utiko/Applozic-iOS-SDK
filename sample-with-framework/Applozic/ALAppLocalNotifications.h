//
//  ALAppLocalNotifications.h
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "ALMessageService.h"
#import "ALChatLauncher.h"

@interface ALAppLocalNotifications : NSObject

+(ALAppLocalNotifications *)appLocalNotificationHandler;

-(void)dataConnectionNotificationHandler;

-(void)reachabilityChanged:(NSNotification*)note;

@property(strong) Reachability * googleReach;
@property(strong) Reachability * localWiFiReach;
@property(strong) Reachability * internetConnectionReach;

@property(nonatomic,strong) ALChatLauncher * chatLauncher;
@property (nonatomic) BOOL flag;
@property(strong,nonatomic) NSDictionary *dict ;
@property(strong,nonatomic) NSString * contactId;
@property(strong,nonatomic) NSMutableDictionary* dict2;

-(void)thirdPartyNotificationTap:(UIGestureRecognizer*)gestureRecognizer;



@end
