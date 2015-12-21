//
//  ApplozicLoginViewController.m
//  applozicdemo
//
//  Created by Devashish on 08/10/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ApplozicLoginViewController.h"
#import <Applozic/ALUser.h>
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALMessageClientService.h>
#import <Applozic/ALRegistrationResponse.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Applozic/ALMessagesViewController.h>
#import <Applozic/ALApplozicSettings.h>
#import <Applozic/ALDataNetworkConnection.h>
#import <Applozic/MBChatManager.h>

@interface ApplozicLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *getStarted;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end

@implementation ApplozicLoginViewController


//-------------------------------------------------------------------------------------------------------------------
//      View lifecycle
//-------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    [ self registerForNotification];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (![ALUserDefaultsHandler getApnDeviceToken]){
        [ self registerForNotification];
    }
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
    [ALDataNetworkConnection checkDataNetworkAvailable];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.getStarted.frame.origin;
    
    CGFloat buttonHeight = self.getStarted.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

//-------------------------------------------------------------------------------------------------------------------
//      IBAction func
//-------------------------------------------------------------------------------------------------------------------

- (IBAction)login:(id)sender {
    
    // Initial login view .....

    MBChatManager *mbChatManager = [[MBChatManager alloc] init];
    [mbChatManager mbChatViewSettings];
    
    NSString *message = [[NSString alloc] initWithFormat: @"Hello %@", [self.userIdField text]];
    NSLog(@"message: %@", message);
    
    if (self.userIdField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"Error" message:@"UserId can't be blank" delegate:self
                                                 cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    //
    ALUser *user = [[ALUser alloc] init];
    [user setApplicationId:@"applozic-sample-app"];
    [user setUserId:[self.userIdField text]];
    [user setEmailId:[self.emailField text]];
    [user setPassword:[self.passwordField text]];
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    
    [self.mActivityIndicator startAnimating];
    [registerUserClientService initWithCompletion:user withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        [self.mActivityIndicator stopAnimating];
        
        if (error) {
            NSLog(@"%@",error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response"
                                                                message:rResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
            [alertView show];
            return ;
        }
        
        if (rResponse && [rResponse.message containsString: @"REGISTERED"])
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage];
        }
        
        NSLog(@"Registration response from server:%@", rResponse);
        
        //-----------------------------------------------------------------------
         // Launching Chat Screens ...
        //-----------------------------------------------------------------------
        
        
//        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle:nil];
//        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LaunchChatFromSimpleViewController"];
//        [self presentViewController:controller animated:YES completion:nil];
     
        [mbChatManager launchChatList:[self.userIdField text] andWithBackButtonTitle:@"< My Chats" andViewControllerObject:self];
        
//        [mbChatManager launchIndividualChat:[self.userIdField text] andViewControllerObject:self];
        
    }];
    
}

//-------------------------------------------------------------------------------------------------------------------
//     Textfield delegate methods
//-------------------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdField) {
        [self.emailField becomeFirstResponder];
    }
    else if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    else {
        //TODO: Also validate user Id and email is entered.
        [textField resignFirstResponder];
    }
    return true;
}

-(void)registerForNotification{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (IBAction)getstarted:(id)sender {
}
@end
