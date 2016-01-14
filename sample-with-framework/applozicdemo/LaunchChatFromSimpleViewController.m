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
@interface LaunchChatFromSimpleViewController ()

- (IBAction)mLaunchChatList:(id)sender;
- (IBAction)mChatLaunchButton:(id)sender;

@end

@implementation LaunchChatFromSimpleViewController

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
    
//            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
//                                                                 bundle:[NSBundle bundleForClass:ALChatViewController.class]];
//            UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
//            [self presentViewController:theTabBar animated:YES completion:nil];
    
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:@"iosdev"];
    [user setEmailId:@""];
    [user setPassword:@""];
    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    //    demoChatManager.userID = user;
    [demoChatManager registerUserAndLaunchChat:user andFromController:self forUser:nil];

}


//===============================================================================
// TO LAUNCH INDIVIDUAL MESSAGE LIST....
//
//===============================================================================

- (IBAction)mChatLaunchButton:(id)sender {
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALChatViewController *chatView =(ALChatViewController*) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    chatView.contactIds =@"applozic";
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:chatView];
    [self presentViewController:conversationViewNavController animated:YES completion:nil];
    
}
@end
