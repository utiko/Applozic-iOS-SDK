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

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mTapGesture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

-(void) scrollTableViewToBottomWithAnimation:(BOOL) animated;

@property (weak, nonatomic) IBOutlet UITextView *sendMessageTextView;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkBottomConstraint;

-(void)loadEarlierButtonAction;

@property (nonatomic, strong) UIButton *loadEarlierAction;

- (IBAction)attachmentActionMethod:(id)sender;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *typingLabel;
@property (nonatomic) BOOL * individualLaunch;
@property (nonatomic, strong) NSString * titleOfView;

-(UIView *)setCustomBackButton;

@end
