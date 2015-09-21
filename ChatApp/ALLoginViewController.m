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


@interface ALLoginViewController ()<UITextFieldDelegate>

    @property (weak, nonatomic) IBOutlet UITextField *userIdField;

    @property (weak, nonatomic) IBOutlet UITextField *emailField;

    @property (weak, nonatomic) IBOutlet UITextField *passwordField;

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
        NSLog(@"clicked");
        NSLog(@"yo working - just getting started!");
        NSString *message = [[NSString alloc] initWithFormat: @"Hello %@", [self.userIdField text]];
        NSLog(@"message: %@", message);

        ALUser *user = [[ALUser alloc] init];
        [user setUserId:[self.userIdField text]];
        [user setEmailId:[self.emailField text]];
        [user setPassword:[self.passwordField text]];

        ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
        
        
        [registerUserClientService createAccountWithCallback:user withCompletion:^(NSString *strData, NSError *error) {
            
            if (error) {
                
                NSLog(@"%@",error);
                
                return ;
            }

        NSLog(@"Registration response from server:%@", strData);
       /*
        ALRegistrationResponse *registrationResponse = [[ALRegistrationResponse alloc] initWithJSONString:strData];
        
        NSLog(@"Converted to registrationresponse object: %@", registrationResponse.message);*/
          
        
      /*  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:registrationResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
        [alertView show];*/
        }];
        
      /*  ALRegistrationResponse *registrationResponse = [registerUserClientService createAccount:user];
        
        NSLog(@"Message: %@", registrationResponse.message);
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:registrationResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
        [alertView show];*/
        
        //[self performSegueWithIdentifier:@"message" sender:self];
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
