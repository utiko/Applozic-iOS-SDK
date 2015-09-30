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

-(void) refresh;

-(void)pushNotificationhandler:(NSNotification *) notification;

@end

