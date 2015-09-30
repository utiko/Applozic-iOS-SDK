//
//  ViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALChatViewController.h"

@interface ALMessagesViewController : UIViewController

@property(nonatomic,strong) ALChatViewController * detailChatViewController;

-(void)pushNotificationhandler:(NSNotification *) notification;

-(void)updateDeliveryReport:(NSNotification *) notification;

@end

