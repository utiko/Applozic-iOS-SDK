//
//  ALBaseViewController.m
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALBaseViewController.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"

@interface ALBaseViewController ()


@property (nonatomic,retain) UIButton * rightViewButton;

@end

@implementation ALBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpTableView];
    [self setUpTheming];
    [self registerForKeyboardNotifications];

    self.tabBarController.tabBar.hidden = YES;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    }

    if ([ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_BACKGROUND_COLOR])
        self.mTableView.backgroundColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_BACKGROUND_COLOR];
    else
        self.mTableView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
}


-(void)setUpTableView {

    UIButton * mLoadEarlierMessagesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mLoadEarlierMessagesButton.frame = CGRectMake(self.view.frame.size.width/2-90, 15, 180, 30);
    [mLoadEarlierMessagesButton setTitle:@"Load Earlier" forState:UIControlStateNormal];
    [mLoadEarlierMessagesButton setBackgroundColor:[UIColor whiteColor] ];
    mLoadEarlierMessagesButton.layer.cornerRadius = 3;
    [mLoadEarlierMessagesButton addTarget:self action:@selector(loadChatView) forControlEvents:UIControlEventTouchUpInside];
    [mLoadEarlierMessagesButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [self.mTableHeaderView addSubview:mLoadEarlierMessagesButton];

    // textfield right view
    self.mSendMessageTextField.rightViewMode = UITextFieldViewModeAlways;
    self.rightViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.rightViewButton setImage:[UIImage imageNamed:@"mobicom_ic_action_send_now2.png"] forState:UIControlStateNormal];
    [self.rightViewButton addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.mSendMessageTextField setRightView:self.rightViewButton];
}

-(void)setUpTheming {
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    if (!color) {
        color = [UIColor blackColor];
    }
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTable:)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navColor = [self.navigationController.navigationBar tintColor];
    } else {
        // iOS 7.0 or later
        self.navColor = [self.navigationController.navigationBar barTintColor];
    }
    UIBarButtonItem * theAttachmentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_action_attachment2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(attachmentAction)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:theAttachmentButton,refreshButton ,nil];
}


-(void)loadChatView {

}

-(void)postMessage {

}

-(void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshTable:(id)sender {

}

-(void)attachmentAction{

}

-(void)viewWillDisappear:(BOOL)animated {

    self.navigationController.navigationBar.barTintColor = self.navColor;
    self.tabBarController.tabBar.hidden = NO;
}

// Setting up keyboard notifications.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Keyboard Post Notifacations
//------------------------------------------------------------------------------------------------------------------

-(void) keyBoardWillShow:(NSNotification *) notification
{
    NSDictionary * theDictionary = notification.userInfo;
    NSString * theAnimationDuration = [theDictionary valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardEndFrame = [(NSValue *)[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.mSendTextFieldBottomConstraint.constant = self.view.frame.size.height - keyboardEndFrame.origin.y;

    [UIView animateWithDuration:theAnimationDuration.doubleValue animations:^{
        [self.view layoutIfNeeded];
        [self scrollTableViewToBottomWithAnimation:YES];
    } completion:^(BOOL finished) {
        if (finished) {
            [self scrollTableViewToBottomWithAnimation:YES];
        }
    }];
}


-(void) keyBoardWillHide:(NSNotification *) notification
{
    NSDictionary * theDictionary = notification.userInfo;
    NSString * theAnimationDuration = [theDictionary valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    self.mSendTextFieldBottomConstraint.constant = 0;
    [UIView animateWithDuration:theAnimationDuration.doubleValue animations:^{
        [self.view layoutIfNeeded];

    }];
}

-(void) scrollTableViewToBottomWithAnimation:(BOOL) animated
{
    if (self.mTableView.contentSize.height > self.mTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.mTableView.contentSize.height - self.mTableView.frame.size.height);
        [self.mTableView setContentOffset:offset animated:animated];
    }
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Textfield Delegates
//------------------------------------------------------------------------------------------------------------------

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark tap gesture

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    if ([self.mSendMessageTextField isFirstResponder]) {
        [self.mSendMessageTextField resignFirstResponder];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
