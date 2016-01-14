//
//  ALChatViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//
#import "ALMapViewController.h"
#import <UIKit/UIKit.h>
#import "ALMessage.h"
#import "ALBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DB_CONTACT.h"
#import "ALContact.h"
#import "ALChatCell.h"
#import "ALAttachmentController.h"
#import "ALUserDetail.h"
#import "ALMessageArrayWrapper.h"

@interface ALChatViewController : ALBaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ALMapViewControllerDelegate,ALChatCellDelegate,ALImageWithTextControllerDelegate>

@property (strong, nonatomic) ALContact *alContact;
@property (strong, nonatomic) ALMessageArrayWrapper *alMessageWrapper;
@property (strong, nonatomic) NSMutableArray *mMessageListArrayKeyStrings;
@property (strong, nonatomic) NSString * contactIds;
@property (nonatomic) BOOL refreshMainView;
@property (nonatomic) BOOL refresh;
@property (strong, nonatomic) NSString * text;

-(void)fetchAndRefresh;
-(void)fetchAndRefresh:(BOOL)flag;

-(void)updateDeliveryReport:(NSString*)keyString;

-(void) updateDeliveryReportForConversation;

-(void)individualNotificationhandler:(NSNotification *) notification;

-(void)updateDeliveryStatus:(NSNotification *) notification;

-(void) syncCall:(NSString *) contactId updateUI:(NSNumber *) updateUI alertValue: (NSString *) alertValue;
-(void) syncCall:(ALMessage *) alMessage;
-(void)showTypingLabel:(BOOL)flag userId:(NSString *)userId;

-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail;
-(void) reloadViewfor3rdParty;
-(void) reloadView;
-(void)processMarkRead;

-(void)handleNotification:(UIGestureRecognizer*)gestureRecognizer;
@end
