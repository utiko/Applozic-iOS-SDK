//
//  ALChatViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMessage.h"
#import "ALBaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ALChatViewController : ALBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>


@property (strong, nonatomic) NSMutableArray *mMessageListArray;
@property (strong, nonatomic) NSString * contactIds;
@property (nonatomic) BOOL refreshMainView;

-(void)fetchAndRefresh;
-(void)updateDeliveryReport:(NSString*)keyString;

-(void)individualNotificationhandler:(NSNotification *) notification;

-(void)updateDeliveryStatus:(NSNotification *) notification;


@end
