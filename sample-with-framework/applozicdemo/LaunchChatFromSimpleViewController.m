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
#import  <Applozic/ALDBHandler.h>
#import  <Applozic/ALContact.h>
#import <Applozic/ALDataNetworkConnection.h>
#import <Applozic/ALContactService.h>

@interface LaunchChatFromSimpleViewController ()

- (IBAction)mLaunchChatList:(id)sender;
- (IBAction)mChatLaunchButton:(id)sender;


@end

@implementation LaunchChatFromSimpleViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self mLaunchChatList:self];
    _activityView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center=self.view.center;

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
    
    if (![ALDataNetworkConnection checkDataNetworkAvailable]){
        [_activityView removeFromSuperview];
    }
    else {
        [_activityView startAnimating];
    }
    [self.view addSubview:_activityView];
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmailId:[ALUserDefaultsHandler getEmailId]];
    [user setPassword:@""];
    
    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    [demoChatManager registerUserAndLaunchChat:user andFromController:self forUser:nil];

    //Adding sample contacts...
    [self insertInitialContacts];


}


//===============================================================================
// TO LAUNCH INDIVIDUAL MESSAGE LIST....
//
//===============================================================================

- (IBAction)mChatLaunchButton:(id)sender {
    
    [self.view addSubview:_activityView];
    [_activityView startAnimating];
    
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmailId:[ALUserDefaultsHandler getEmailId]];
    [user setPassword:@""];
    
    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    [demoChatManager launchChatForUserWithDisplayName:@"masterUser" andwithDisplayName:@"Master" andFromViewController:self];
    
}

-(void)viewWillAppear:(BOOL)animated{
//    [activityView stopAnimating];
//    [_activityView removeFromSuperview];
}
-(void)viewWillDisappear:(BOOL)animated {
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
}

-(void)whenPush{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                            bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController* theLauncg =[storyboard instantiateViewControllerWithIdentifier:@"LaunchChatFromSimpleViewController"];
      UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
    [self presentViewController:theLauncg animated:YES completion:nil];
        [self presentViewController:theTabBar animated:YES completion:nil];
}

- (IBAction)logoutBtn:(id)sender {
    ALRegisterUserClientService * alUserClientService = [[ALRegisterUserClientService alloc]init];
    
    if([ALUserDefaultsHandler getDeviceKeyString]){
        alUserClientService.logout;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) insertInitialContacts{
    
    ALContactService * contactService = [[ALContactService alloc] init];
    
    // Contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"adarshk";
    contact1.fullName = @"Adarsh Kumar";
    contact1.displayName = @"Adarsh";
    contact1.email = @"github@applozic.com";
    contact1.contactImageUrl = nil;
    contact1.localImageResourceName = @"";
    
    
    // Contact 2 -------- Example with json
    NSString *jsonString =@"{\"userId\": \"applozic\",\"fullName\": \"Applozic\",\"contactNumber\": \"9535008745\",\"displayName\": \"Applozic Support\",\"contactImageUrl\": \"http://applozic.com/resources/images/aboutus/rathan.jpg\",\"email\": \"devashish@applozic.com\",\"localImageResourceName\":\"rathan.jpg\"}";
    ALContact *contact2 = [[ALContact alloc] initWithJSONString:jsonString];
    
    
    // Contact 3 ------- Example with dictonary
    NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init];
    [demodictionary setValue:@"abhishek" forKey:@"userId"];
    [demodictionary setValue:@"Abhishek" forKey:@"fullName"];
    [demodictionary setValue:@"1234567890" forKey:@"contactNumber"];
    [demodictionary setValue:@"Abhishek" forKey:@"displayName"];
    [demodictionary setValue:@"github@applozic.com" forKey:@"email"];
    [demodictionary setValue:@"https://www.applozic.com/resources/images/applozic_logo.gif" forKey:@"contactImageUrl"];
    [demodictionary setValue:nil forKey:@"localImageResourceName"];
    [demodictionary setValue:[ALUserDefaultsHandler getApplicationKey] forKey:@"applicationId"];
    ALContact *contact3 = [[ALContact alloc] initWithDict:demodictionary];
    
    [contactService insertInitialContactsService:@[contact1,contact2,contact3]];
}

@end
