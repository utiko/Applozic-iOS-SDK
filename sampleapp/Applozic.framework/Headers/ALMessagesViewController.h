//
//  ViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALChatViewController.h"
#import "ALContactCell.h"

@interface ALMessagesViewController : UIViewController

@property(nonatomic,strong) ALChatViewController * detailChatViewController;

-(void)createDetailChatViewController: (NSString *) contactIds;

-(void) syncCall: (ALMessage *) alMessage;

-(void)pushNotificationhandler:(NSNotification *) notification;

-(void)displayAttachmentMediaType:(ALMessage *)message andContactCell:(ALContactCell *)contactCell;

@end

