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

@interface LaunchChatFromSimpleViewController ()

- (IBAction)mLaunchChatList:(id)sender;
- (IBAction)mChatLaunchButton:(id)sender;
@property(nonatomic,strong) UIActivityIndicatorView *activityView;

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
    
    
    [_activityView startAnimating];
    
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
    [_activityView removeFromSuperview];
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
    
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    //contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"adarshk";
    contact1.fullName = @"Rathan";
    contact1.contactNumber = @"1234561234";
    contact1.displayName = @"Rathan";
    contact1.email = @"123@abc.com";
    contact1.contactImageUrl = nil;
    contact1.localImageResourceName = @"1.jpg";
    contact1.applicationId = [ALUserDefaultsHandler getApplicationKey];
    
    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"marvel";
    contact2.fullName = @"abhishek thapliyal";
    contact2.contactNumber = @"987651234";
    contact2.displayName = @"abhishek";
    contact2.email = @"456@abc.com";
    contact2.contactImageUrl = nil;
    contact2.localImageResourceName = @"1.jpg";
    contact2.applicationId = [ALUserDefaultsHandler getApplicationKey];
    
    ALContact *contact3 = [[ALContact alloc] init];
    contact3.userId = @"don";
    contact3.fullName = @"DON";
    contact3.contactNumber = @"1299834";
    contact3.displayName = @"DON";
    contact3.email = @"don@baba.com";
    contact3.contactImageUrl = @"http://tinyhousetalk.com/wp-content/uploads/320-Sq-Ft-Orange-Container-Guest-House-00.jpg";
    contact3.localImageResourceName = nil;
    contact3.applicationId = [ALUserDefaultsHandler getApplicationKey];
    
    
    //Contact -------- Example with json
    
    //    NSString *jsonString =@"{\"userId\": \"applozic\",\"fullName\": \"Applozic\",\"contactNumber\": \"9535008745\",\"displayName\": \"Applozic Support\",\"contactImageUrl\": \"http://applozic.com/resources/images/aboutus/rathan.jpg\",\"email\": \"devashish@applozic.com\",\"localImageResourceName\":null}";
    //
    //    ALContact *contact4 = [[ALContact alloc] initWithJSONString:jsonString];
    //
    //    //Contact ------- Example with dictonary
    
    NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init];
    [demodictionary setValue:@"aman999" forKey:@"userId"];
    [demodictionary setValue:@"aman sharma" forKey:@"fullName"];
    [demodictionary setValue:@"75760462" forKey:@"contactNumber"];
    [demodictionary setValue:@"aman" forKey:@"displayName"];
    [demodictionary setValue:@"aman@applozic.com" forKey:@"email"];
    [demodictionary setValue:@"http://images.landofnod.com/is/image/LandOfNod/Letter_Giant_Enough_A_231533_LL/$web_zoom$&wid=550&hei=550&/1308310656/not-giant-enough-letter-a.jpg" forKey:@"contactImageUrl"];
    [demodictionary setValue:nil forKey:@"localImageResourceName"];
    [demodictionary setValue:[ALUserDefaultsHandler getApplicationKey] forKey:@"applicationId"];
    
    ALContact *contact5 = [[ALContact alloc] initWithDict:demodictionary];
    //   [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact4, contact5]];
    [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact5]];
    
}

@end
