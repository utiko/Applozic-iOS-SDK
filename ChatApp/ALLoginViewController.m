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


@interface ALLoginViewController ()

@end

@implementation ALLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)login:(id)sender {
    NSLog(@"clicked");
    NSLog(@"yo working - just getting started!");
    NSString *message = [[NSString alloc] initWithFormat: @"Hello %@", [_userId text]];
    NSLog(@"message: %@", message);
    
    
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[_userId text]];
    [user setEmailId:[_emailId text]];
    [user setPassword:[_password text]];
    [user setApplicationId:@"mobicomkit-sample-app"];
    [user setDeviceType:1];
    [user setPrefContactAPI:2];
    [user setEmailVerified:TRUE];
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    
    
    [registerUserClientService createAccountWithCallback:user withCompletion:^(NSString *strData, NSError *error) {
        
        if (error) {
            
            NSLog(@"%@",error);
            
            return ;
        }
        
        
        NSLog(@"Registration response from server:%@", strData);
        
        ALRegistrationResponse *registrationResponse = [[ALRegistrationResponse alloc] initWithJSONString:strData];
        
        NSLog(@"Converted to registrationresponse object: %@", registrationResponse.message);
          
        
      /*  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:registrationResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
        [alertView show];*/
    }];
    
  /*  ALRegistrationResponse *registrationResponse = [registerUserClientService createAccount:user];
    
    NSLog(@"Message: %@", registrationResponse.message);
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:registrationResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    [alertView show];*/
    
    //[self performSegueWithIdentifier:@"message" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
