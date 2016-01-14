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
#import  <Applozic/ALUserDefaultsHandler.h>
#import  <Applozic/ALRegisterUserClientService.h>


@interface LaunchChatFromSimpleViewController ()

- (IBAction)mLaunchChatList:(id)sender;
- (IBAction)mChatLaunchButton:(id)sender;

@end

@implementation LaunchChatFromSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self mLaunchChatList:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutButton:(id)sender {
    
    ALRegisterUserClientService * alUserClientService = [[ALRegisterUserClientService alloc]init];
    
    if([ALUserDefaultsHandler getDeviceKeyString]){
        alUserClientService.logout;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
    
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmailId:[ALUserDefaultsHandler getEmailId]];
    [user setPassword:@""];
    
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
    [user setPassword:@""];
    
    
    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    [demoChatManager registerUserAndLaunchChat:user andFromController:self forUser:@"adarshk"];
}

-(void)whenPush{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                            bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController* theLauncg =[storyboard instantiateViewControllerWithIdentifier:@"LaunchChatFromSimpleViewController"];
      UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
    [self presentViewController:theLauncg animated:YES completion:nil];
        [self presentViewController:theTabBar animated:YES completion:nil];
}

@end
