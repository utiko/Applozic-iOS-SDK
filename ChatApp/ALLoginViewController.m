//
//  ALLoginViewController.m
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALLoginViewController.h"
#import "ALUser.h"
#import "ALRegistrationResponse.h"
#import "ALRegisterUserClientService.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageClientService.h"
#import "ALUtilityClass.h"


@interface ALLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *getStarted;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end

@implementation ALLoginViewController

//-------------------------------------------------------------------------------------------------------------------
//      View lifecycle
//-------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
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

    NSString *message = [[NSString alloc] initWithFormat: @"Hello %@", [self.userIdField text]];
    NSLog(@"message: %@", message);
    
    if (self.userIdField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"Error" message:@"UserId can't be blank" delegate:self
                                                 cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }


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
        
        [self performSegueWithIdentifier:@"MessagesViewController" sender:self];

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


@end
