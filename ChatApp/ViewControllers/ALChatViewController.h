//
//  ALChatViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMessage.h"
#import "ALBaseViewController.h"

@interface ALChatViewController : ALBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (strong, nonatomic) NSMutableArray *mMessageListArray;

@property (strong, nonatomic) ALMessage * mLatestMessage;


@end
