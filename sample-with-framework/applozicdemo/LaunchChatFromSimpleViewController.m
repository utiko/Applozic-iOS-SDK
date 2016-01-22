//
//  LaunchChatFromSimpleViewController.m
//  applozicdemo
//
//  Created by Devashish on 13/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "LaunchChatFromSimpleViewController.h"
#import  <Applozic/ALChatViewController.h>
#import "DemoChatManager.h"
#import "ApplozicLoginViewController.h"
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALRegisterUserClientService.h>
@interface LaunchChatFromSimpleViewController ()

- (IBAction)mLaunchChatList:(id)sender;
- (IBAction)mChatLaunchButton:(id)sender;

@end

@implementation LaunchChatFromSimpleViewController{
    UIActivityIndicatorView *activityView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//===============================================================================
// TO LAUNCH MESSAGE LIST.....
//
//===============================================================================

- (IBAction)mLaunchChatList:(id)sender {
    
    activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
  
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmailId:[ALUserDefaultsHandler getEmailId]];
    [user setApplicationId:@"applozic-sample-app"];//[user setPassword:@""];
    
    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    [demoChatManager registerUserAndLaunchChat:user andFromController:self forUser:nil];

}


//===============================================================================
// TO LAUNCH INDIVIDUAL MESSAGE LIST....
//
//===============================================================================

- (IBAction)mChatLaunchButton:(id)sender {
    
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmailId:[ALUserDefaultsHandler getEmailId]];
    //[user setPassword:@""];

    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    [demoChatManager launchChatForUserWithDisplayName:@"nayawalauser" andwithDisplayName:@"Adarsh New" andFromViewController:self];
    

    
}

-(void)viewWillDisappear:(BOOL)animated {
    [activityView removeFromSuperview];
}

- (IBAction)logoutBtn:(id)sender {
    ALRegisterUserClientService * alUserClientService = [[ALRegisterUserClientService alloc]init];
    
    if([ALUserDefaultsHandler getDeviceKeyString]){
        alUserClientService.logout;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
