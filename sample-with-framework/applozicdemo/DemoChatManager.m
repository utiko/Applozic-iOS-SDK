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

@implementation DemoChatManager

// ----------------------

// Call This at time of your app's user authentication OR User registration.
// This will register your User at applozic server.


//----------------------

-(void)registerUser:(ALUser *)alUser{
    
        self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
    
        [self.chatLauncher mbChatViewSettings];
        ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
        [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        if (error) {
             //Handle Registration error here ....
                NSLog(@"%@",error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response: Cannot Register User Client"
                                          
                                                                    message:rResponse.message delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                
                [alertView show];
                
                return ;
                
            }
            if (rResponse && [rResponse.message containsString: @"REGISTERED"])
            {                ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
                [messageClientService addWelcomeMessage];

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
   [ self registerUserAndLaunchChat:nil andFromController:fromViewController forUser:nil];
}


// ----------------------  ------------------------------------------------------/

// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/

-(void)launchChatForUserWithDefaultText:(NSString * )userId andFromViewController:(UIViewController*)fromViewController{
  
    [ self registerUserAndLaunchChat:nil andFromController:fromViewController forUser:userId];

}


// ----------------------  ------------------------------------------------------/

// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/

-(void)launchChatForUserWithDisplayName:(NSString * )userId andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController{
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];

    if([ALUserDefaultsHandler getDeviceKeyString]){
        
        [self.chatLauncher launchIndividualChat:userId withDisplayName:displayName andViewControllerObject:fromViewController andWithText:nil];
        
        return;
    }
    
    [self.chatLauncher mbChatViewSettings];
    ALUser *alUser =  DemoChatManager.getLoggedinUserInformation;

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
            [messageClientService addWelcomeMessage];
            
        }
        [self.chatLauncher launchIndividualChat:userId withDisplayName:displayName andViewControllerObject:fromViewController andWithText:nil]; 
        if(![ALUserDefaultsHandler getApnDeviceToken]){
            [self.chatLauncher registerForNotification];
        }
        
        
        NSLog(@"Registration response from server:%@", rResponse);
    }];
}

// ----------------------  ------------------------------------------------------/

//      Method to register + lauch chats screen. If user is already registered, directly chats screen will be launched.
//      If user information is not passed, it will try to get user information from getLoggedinUserInformation.
//
//
//-----------------------  ------------------------------------------------------/


-(void)registerUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController*)viewController forUser:(NSString*)userId {
   
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
   
    
    //User is already registered ..directly launch the chat...
    if([ALUserDefaultsHandler getDeviceKeyString]){
        
        if(userId){
            [self.chatLauncher launchIndividualChat:userId andViewControllerObject:viewController andWithText:nil];
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
    [self.chatLauncher mbChatViewSettings];
    
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
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage];
        }

        if(![ALUserDefaultsHandler getApnDeviceToken]){
            [self.chatLauncher registerForNotification];
            NSLog(@"Called...for notification");

        }
        
        if(userId){
            [self.chatLauncher launchIndividualChat:userId andViewControllerObject:viewController andWithText:nil];
        }else{
            NSString * title = viewController.title? viewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:viewController ];
        }
        
        NSLog(@"Registration response from server:%@", rResponse);
    }];

    
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





@end
