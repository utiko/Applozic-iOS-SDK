//
//  ALChatViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMessage.h"

@interface ALChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (strong, nonatomic) NSMutableArray *mMessageListArray;

@property (strong, nonatomic) ALMessage * mLatestMessage;

@property (weak, nonatomic) IBOutlet UITextField *mSendMessageTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mSendTextFieldBottomConstraint;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mTapGesture;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end
