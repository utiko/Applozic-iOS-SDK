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
#define APPLICATION_ID @"applozic-sample-app"
//#define APPLICATION_ID @"26f0af2e3a50c8d0c4f08a9f1dbe684a6"


@interface ALLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *getStarted;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *errorlabel;

@property (weak, nonatomic) IBOutlet UILabel *erroruser;
- (void)markField:(BOOL)flag;
- (BOOL)validateEmail:(NSString *)emailStr;

@end

@implementation ALLoginViewController

//-------------------------------------------------------------------------------------------------------------------
//      View lifecycle
//-------------------------------------------------------------------------------------------------------------------

@synthesize emailField, errorlabel, erroruser;

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
    
    NSString *email = emailField.text;
    BOOL authenticate = NO;
   /* if([email isEqualToString:@""]||(![self validateEmail:email]))
    {
        [self markField:false];
        errorlabel.text = NSLocalizedString(@"ERROR_EMAIL_ID", nil);
       // errorlabel.text=@"incoreet email";
        errorlabel.hidden = NO;
        authenticate = YES;
    }
    else
    {
        [self markField:true];
    }
    */
    if (self.userIdField.text.length == 0|| authenticate ==YES) {
        /*  UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
         @"Error" message:@"UserId/Email ID can't be blank" delegate:self
         cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
         [alertView show];*/
        erroruser.text = NSLocalizedString(@"ERROR_USER_ID", nil);
       // erroruser.text =@"error user id";
        erroruser.hidden = NO;
        return;
    }

    [ALUserDefaultsHandler setLogoutButtonHidden: NO];
    [ALUserDefaultsHandler setBottomTabBarHidden:NO];
    
    ALUser *user = [[ALUser alloc] init];
    [user setApplicationId:APPLICATION_ID];
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
            [messageClientService addWelcomeMessage:nil];
        }
        
        NSLog(@"Registration response from server:%@", rResponse);
        
        [self performSegueWithIdentifier:@"MessagesViewController" sender:self];
        
        
    }];
    
    
    
    
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)markField:(BOOL)flag
{
    if(flag==false){
        emailField.layer.masksToBounds=YES;
        emailField.layer.borderColor=[[UIColor redColor] CGColor];
        emailField.layer.borderWidth=1.0f;
        
    }
    else
    {
        emailField.layer.borderColor=[[UIColor clearColor] CGColor];
    }
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

@end
