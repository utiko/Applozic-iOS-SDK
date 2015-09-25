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


@interface ALLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end

@implementation ALLoginViewController

//-------------------------------------------------------------------------------------------------------------------
//      View lifecycle
//-------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-------------------------------------------------------------------------------------------------------------------
//      IBAction func
//-------------------------------------------------------------------------------------------------------------------

- (IBAction)login:(id)sender {

    NSString *message = [[NSString alloc] initWithFormat: @"Hello %@", [self.userIdField text]];
    NSLog(@"message: %@", message);

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


        [ALUserDefaultsHandler setUserId:[user userId]];

        NSLog(@"Registration response from server:%@", rResponse);
        
        [self performSegueWithIdentifier:@"MessagesViewController" sender:self];

        /*
         ALRegistrationResponse *registrationResponse = [[ALRegistrationResponse alloc] initWithJSONString:strData];

         NSLog(@"Converted to registrationresponse object: %@", registrationResponse.message);*/
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
