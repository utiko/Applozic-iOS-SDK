//
//  ALBaseViewController.h
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALBaseViewController : UIViewController

@property (nonatomic, retain) UIColor *navColor;
@property (nonatomic,retain) UIView * mTableHeaderView;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UITextField *mSendMessageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mSendTextFieldBottomConstraint;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mTapGesture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

-(void) scrollTableViewToBottomWithAnimation:(BOOL) animated;


@end
