//
//  ALBaseViewController.m
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define NAVIGATION_TEXT_SIZE 20
#define LAST_SEEN_LABEL_SIZE 10
#define TYPING_LABEL_SIZE 12.5
#define MQTT_MAX_RETRY 3


#import "ALBaseViewController.h"
#import "ALUtilityClass.h"
#import "ALUserDefaultsHandler.h"
#import "ALConstant.h"
#import "ALApplozicSettings.h"
#import "ALChatLauncher.h"
#import "ALMessagesViewController.h"

#define KEYBOARD_PADDING 85

@interface ALBaseViewController ()<UITextViewDelegate>


@property (nonatomic,retain) UIButton * rightViewButton;

@end

@implementation ALBaseViewController
{
    CGFloat typingIndicatorHeight;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    [self setUpTheming];
    [self registerForKeyboardNotifications];
    
    self.sendMessageTextView.delegate = self;
    
  
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


-(void)setUpTableView
{
    
    UIButton * mLoadEarlierMessagesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mLoadEarlierMessagesButton.frame = CGRectMake(self.view.frame.size.width/2-90, 15, 180, 30);
    [mLoadEarlierMessagesButton setTitle:@"Load Earlier" forState:UIControlStateNormal];
    [mLoadEarlierMessagesButton setBackgroundColor:[UIColor whiteColor] ];
    mLoadEarlierMessagesButton.layer.cornerRadius = 3;
    [mLoadEarlierMessagesButton addTarget:self action:@selector(loadChatView) forControlEvents:UIControlEventTouchUpInside];
    [mLoadEarlierMessagesButton.titleLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
    [self.mTableHeaderView addSubview:mLoadEarlierMessagesButton];

}

-(void)setUpTheming
{
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    
    if (!color)
    {
        color = [UIColor blackColor];
        //        color = [UIColor whiteColor];
    }
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< My Chats" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton]];
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTable:)];
    
    self.callButton = [[UIBarButtonItem alloc] initWithImage:[ALUtilityClass getImageFromFramworkBundle:@"PhoneCallFilledXXS.png"]
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(phoneCallMethod)];

    
    if(self.individualLaunch)
    {
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navColor = [self.navigationController.navigationBar tintColor];
    } else {
        // iOS 7.0 or later
        self.navColor = [self.navigationController.navigationBar barTintColor];
    }
    
    self.navRightBarButtonItems = [NSMutableArray new];

    if(![ALApplozicSettings isRefreshButtonHidden])
    {
        [self.navRightBarButtonItems addObject:refreshButton];
    }

    self.navigationItem.rightBarButtonItems = [self.navRightBarButtonItems mutableCopy];
    
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    [self.label setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:LAST_SEEN_LABEL_SIZE]];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:self.label];
    
    typingIndicatorHeight = 30;
    
    self.typingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.typingMessageView.frame.origin.y - typingIndicatorHeight,
                                                                 self.view.frame.size.width, typingIndicatorHeight)];
    
    self.typingLabel.backgroundColor = [ALApplozicSettings getBGColorForTypingLabel];
    self.typingLabel.textColor = [ALApplozicSettings getTextColorForTypingLabel];
    self.typingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.typingLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:TYPING_LABEL_SIZE]];
    self.typingLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.typingLabel];
 
    [self dropShadowInNavigationBar];
}

-(void)dropShadowInNavigationBar
{
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationController.navigationBar.layer.shadowRadius = 10;
    self.navigationController.navigationBar.layer.masksToBounds = NO;
}

-(void)loadChatView {
    
}

-(void)postMessage {
    
}

-(void)back:(id)sender {
    
    UIViewController *  uiController = [self.navigationController popViewControllerAnimated:YES];
    if(!uiController ){
        if(self.individualLaunch){
            [self  dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)refreshTable:(id)sender {
    
}

-(void)attachmentAction{
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
        //self.navigationController.navigationBar.translucent = NO;
        //[self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [ALApplozicSettings getColorForNavigationItem], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
       // [self.navigationController.navigationBar setBackgroundColor: [ALApplozicSettings getColorForNavigation]];

        [self.label setTextColor:[ALApplozicSettings getColorForNavigationItem]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  //set color of setTintColor to ehite then this will change to white
    }

    [self sendButtonUI];
    
}

-(void)sendButtonUI
{
    [self.sendButton setBackgroundColor:[ALApplozicSettings getColorForSendButton]];
    self.sendButton.layer.cornerRadius = self.sendButton.frame.size.width/2;
    self.sendButton.layer.masksToBounds = YES;
    
    [self.typingMessageView sendSubviewToBack:self.typeMsgBG];
    UIImage * image = [[ALUtilityClass getImageFromFramworkBundle:@"TYMSGBG.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 10, 20)];
    
    [self.typeMsgBG setImage:image];
    [self.typingMessageView setBackgroundColor:[ALApplozicSettings getColorForTypeMsgBackground]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = self.navColor;
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
    
    CGFloat navigationWidth = self.navigationController.navigationBar.frame.size.height +
                                [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.checkBottomConstraint.constant = self.view.frame.size.height - keyboardEndFrame.origin.y + navigationWidth;
    
//    self.typingLabel.frame = CGRectMake(0, keyboardEndFrame.origin.y - (KEYBOARD_PADDING + navigationWidth), self.view.frame.size.width, 30);
    
    self.typingLabel.frame = CGRectMake(0,
                            keyboardEndFrame.origin.y - (self.typingMessageView.frame.size.height + typingIndicatorHeight + navigationWidth),
                            self.view.frame.size.width, typingIndicatorHeight);
    
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
    self.checkBottomConstraint.constant = 0;
    CGRect keyboardEndFrame = [(NSValue *)[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat navigationWidth = self.navigationController.navigationBar.frame.size.height +
                                [UIApplication sharedApplication].statusBarFrame.size.height;
    
//    self.typingLabel.frame = CGRectMake(0, keyboardEndFrame.origin.y - (KEYBOARD_PADDING + navigationWidth), self.view.frame.size.width, 30);
    
    self.typingLabel.frame = CGRectMake(0,
                            keyboardEndFrame.origin.y - (self.typingMessageView.frame.size.height + typingIndicatorHeight + navigationWidth),
                            self.view.frame.size.width, typingIndicatorHeight);
    
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

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    [self.sendMessageTextView resignFirstResponder];
}

#pragma mark tap gesture

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    if ([self.sendMessageTextView isFirstResponder]) {
        [self.sendMessageTextView resignFirstResponder];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sendAction:(id)sender
{
    NSCharacterSet *charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@"  \n\""];
    self.sendMessageTextView.text = [self.sendMessageTextView.text stringByTrimmingCharactersInSet:charsToTrim];
  
    if(self.sendMessageTextView.text.length > 0)
    {
        [self postMessage];
    }
    
}
- (IBAction)attachmentActionMethod:(id)sender {
    [self attachmentAction];
}

-(UIView *)setCustomBackButton
{
    UIImageView *imageView=[[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , 20, 15)];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:[ALApplozicSettings getTitleForBackButtonChatVC]];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    
//    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
//    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:button];
    
    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    backTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:backTap];

    
    
    return view;
    
}

@end
