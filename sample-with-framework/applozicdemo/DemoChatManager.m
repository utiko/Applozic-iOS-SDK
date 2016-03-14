//
//  DemoChatManager.m
//  applozicdemo
//
//  Created by Adarsh on 28/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "DemoChatManager.h"
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Applozic/ALMessageClientService.h>
#import "LaunchChatFromSimpleViewController.h"
#import <Applozic/ALApplozicSettings.h>

@implementation DemoChatManager

// ----------------------

// Call This at time of your app's user authentication OR User registration.
// This will register your User at applozic server.


//----------------------

-(void)registerUser:(ALUser *)alUser{
    
        self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];

        //[self.chatLauncher ALDefaultChatViewSettings];
        [self ALDefaultChatViewSettings];
        [alUser setApplicationId:APPLICATION_ID];
        ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
        [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        if (error) {
             //Handle Registration error here ....
                NSLog(@"%@",error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response"
                                          
                                                                    message:rResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                
                [alertView show];
                
                return ;
                
            }
            if (rResponse && [rResponse.message containsString: @"REGISTERED"])
            {                ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
                [messageClientService addWelcomeMessage:nil];

            }
            
            if(![ALUserDefaultsHandler getApnDeviceToken]){
                [self.chatLauncher registerForNotification];
            }
            

            NSLog(@"Registration response from server:%@", rResponse);
        }];
}



// ----------------------  ------------------------------------------------------/

// convenient method to launch chat-list, after user registration is done on applozic server.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/


-(void)launchChat: (UIViewController *)fromViewController{
   [ self registerUserAndLaunchChat:nil andFromController:fromViewController forUser:nil withGroupId:nil];
}


// ----------------------  ------------------------------------------------------/

// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/

-(void)launchChatForUserWithDefaultText:(NSString * )userId andFromViewController:(UIViewController*)fromViewController{
  
    [ self registerUserAndLaunchChat:nil andFromController:fromViewController forUser:userId withGroupId:nil];

}



// ----------------------  ------------------------------------------------------/

//      Method to register + lauch chats screen. If user is already registered, directly chats screen will be launched.
//      If user information is not passed, it will try to get user information from getLoggedinUserInformation.
//
//
//-----------------------  ------------------------------------------------------/


-(void)registerUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController*)viewController forUser:(NSString*)userId withGroupId:(NSNumber*)groupID{
   
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
   
    
    //User is already registered ..directly launch the chat...
    if([ALUserDefaultsHandler getDeviceKeyString]){
        
        LaunchChatFromSimpleViewController *lObj=[[LaunchChatFromSimpleViewController alloc] init];
        [lObj.activityView removeFromSuperview];
        if(userId){
            [self.chatLauncher launchIndividualChat:userId withGroupId:groupID andViewControllerObject:viewController andWithText:nil];
        }else{
            NSString * title = viewController.title? viewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:viewController ];
        }
        return;
    }
    
    //Registartion Reuired....
    alUser = alUser ?alUser: DemoChatManager.getLoggedinUserInformation;
    
    if(!alUser){
        NSLog(@"Not able to find user detail for registration...please register with applozic server first");
        return;
    }
    [ alUser setApplicationId:APPLICATION_ID ];
    [self.chatLauncher ALDefaultChatViewSettings];
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        if (error) {
            //Handle Registration error here ....
            NSLog(@"%@",error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response: Cant Register User Client"
                                      
                                                                message:rResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
            
            [alertView show];
            
            return ;
            
        }
        if (rResponse && [rResponse.message containsString: @"REGISTERED"])
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage:nil];
        }
        
        if(![ALUserDefaultsHandler getApnDeviceToken]){
            [self.chatLauncher registerForNotification];
        }
        

        if(userId){
            [self.chatLauncher launchIndividualChat:userId withGroupId:groupID andViewControllerObject:viewController andWithText:nil];
        }else{
            NSString * title = viewController.title? viewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:viewController ];
        }
        
        NSLog(@"Registration response from server:%@", rResponse);
    }];

    
}

// ----------------------  ------------------------------------------------------/

// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController{
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
    
    if([ALUserDefaultsHandler getDeviceKeyString]){
        [self.chatLauncher launchIndividualChat:userId withGroupId:groupID withDisplayName:displayName andViewControllerObject:fromViewController andWithText:nil];
        return;
    }
    
    [self.chatLauncher ALDefaultChatViewSettings];
    ALUser *alUser =  DemoChatManager.getLoggedinUserInformation;
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        if (error) {
            //Handle Registration error here ....
            NSLog(@"%@",error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response" message:rResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
            
            [alertView show];
            
            return ;
            
        }
        if (rResponse && [rResponse.message containsString: @"REGISTERED"])
        {                ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage:nil];
            
        }
        [self.chatLauncher launchIndividualChat:userId withGroupId:groupID withDisplayName:displayName andViewControllerObject:fromViewController andWithText:nil];

        if(![ALUserDefaultsHandler getApnDeviceToken]){
            [self.chatLauncher registerForNotification];
        }
        
        
        NSLog(@"Registration response from server:%@", rResponse);
    }];
}

// ----------------------  ------------------------------------------------------/

// convenient method to directly launch individual context-based user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/


-(void)createAndLaunchChatWithSellerWithConversationProxy:(ALConversationProxy*)alConversationProxy fromViewController:(UIViewController*)fromViewController{
   
    ALConversationService * alconversationService = [[ALConversationService alloc] init];
    [alconversationService  createConversation:alConversationProxy withCompletion:^(NSError *error,ALConversationProxy * proxyObject) {
        if(!error){
            self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
            if([ALUserDefaultsHandler getDeviceKeyString]){
                ALConversationProxy * finalProxy = [self makeFinalProxyWithGeneratedProxy:alConversationProxy andFinalProxy:proxyObject];
                [self.chatLauncher launchIndividualContextChat:finalProxy andViewControllerObject:fromViewController andWithText:nil];
                
            }
            
        }
    }];
    
    
}
//----------------------------------------------------------------------------------------------------
// The below method combines the conversationID got from server's response with the details already set.
//----------------------------------------------------------------------------------------------------
-(ALConversationProxy *)makeFinalProxyWithGeneratedProxy:(ALConversationProxy *)generatedProxy andFinalProxy:(ALConversationProxy *)responseProxy{
    ALConversationProxy * finalProxy = [[ALConversationProxy alloc] init];
    finalProxy.userId = generatedProxy.userId;
    finalProxy.topicDetailJson = generatedProxy.topicDetailJson;
    finalProxy.Id = responseProxy.Id;
    finalProxy.groupId = responseProxy.groupId;
    
    return finalProxy;
    
}
// ----------------------  ---------------------------------------------------------------------------------------------------//

//     This method can be used to get app logged-in user's information.
//     if user information is stored in DB or preference, Code to get user's information should go here.
//     This might be used to get existing user information in case of app update.

//----------------------  ----------------------------------------------------------------------------------------------------//
    
    
    
+( ALUser * )getLoggedinUserInformation{

    ALUser *user = [[ALUser alloc] init];
    [user setApplicationId:APPLICATION_ID];
    
    //random userId. Write your logic to get user information here.
    [user setUserId:@"demo-test"];
    
    //[user setEmailId:[self.emailField text]];
    //[user setPassword:[self.passwordField text]];
    
    return user;
}

//--------------------------------------------------------------------------------------------------------------
// This method helps you customise various settings
//--------------------------------------------------------------------------------------------------------------

-(void)ALDefaultChatViewSettings
{
    [ALUserDefaultsHandler setLogoutButtonHidden:NO];
    [ALUserDefaultsHandler setBottomTabBarHidden:NO];
    [ALApplozicSettings setUserProfileHidden:NO];
    [ALApplozicSettings hideRefreshButton:NO];
    [ALApplozicSettings setTitleForConversationScreen:@"Chats"];
    
    [ALApplozicSettings setFontFace:@"Helvetica"];
    [ALApplozicSettings setColorForReceiveMessages:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1]];
    [ALApplozicSettings setColorForSendMessages:[UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
    [ALApplozicSettings setColorForNavigation: [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
    [ALApplozicSettings setColorForNavigationItem: [UIColor whiteColor]];
    
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    [ALApplozicSettings setNotificationTitle:appName];
    [ALApplozicSettings setMaxCompressionFactor:0.1f];
    [ALApplozicSettings setMaxImageSizeForUploadInMB:3];
    
    [ALApplozicSettings setGroupOption:YES];
}

@end
