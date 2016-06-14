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
#import <Applozic/ALChatViewController.h>
#import <Applozic/ALMessage.h>

@implementation DemoChatManager

// ----------------------

// Call This at time of your app's user authentication OR User registration.
// This will register your User at applozic server.


//----------------------

-(void)registerUser:(ALUser *)alUser{
    
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
    
    //////////////////////////   SET AUTHENTICATION-TYPE-ID FOR INTERNAL USAGE ONLY ////////////////////////
    [ALUserDefaultsHandler setUserAuthenticationTypeId:(short)APPLOZIC];
    ////////////////////////// ////////////////////////// ////////////////////////// ///////////////////////
    
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


-(void)registerUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController*)viewController forUser:(NSString*)userId withGroupId:(NSNumber*)groupID
{
    self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:APPLICATION_ID];
    
    
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
    
    //Registartion Required....
    alUser = alUser ? alUser : [DemoChatManager getLoggedinUserInformation];
    
    if(!alUser){
        NSLog(@"Not able to find user detail for registration...please register with applozic server first");
        return;
    }

    [self ALDefaultChatViewSettings];
    [alUser setApplicationId:APPLICATION_ID ];
    [alUser setAppModuleName: [ALUserDefaultsHandler getAppModuleName]];     // 2. APP_MODULE_NAME setter
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if (error) {
            //Handle Registration error here ....
            NSLog(@"REGISTRATION_ERROR : %@",error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response: Cant Register User Client"
                                                                message:rResponse.message
                                                               delegate: nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles: nil, nil];
            
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

-(BOOL)isUserHaveMessages:(NSString *)userId
{
    ALMessageService * msgService = [ALMessageService new];
    NSUInteger count = [msgService getMessagsCountForUser:userId];
    NSLog(@"COUNT MESSAGES :: %lu",(unsigned long)count);
    return (count == 0);
}

// ----------------------  ------------------------------------------------------/

// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.

// ----------------------  ------------------------------------------------------/

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController
{
    self.chatLauncher = [[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
    
    BOOL flagForText = [self isUserHaveMessages:userId];
    NSString * preText = nil;
    if(flagForText)
    {
        preText = @""; // SET TEXT HERE
    }
    
    if([ALUserDefaultsHandler getDeviceKeyString])
    {
        [self.chatLauncher launchIndividualChat:userId withGroupId:groupID withDisplayName:displayName andViewControllerObject:fromViewController andWithText:preText];
        return;
    }
    
    [self ALDefaultChatViewSettings];
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
        [self.chatLauncher launchIndividualChat:userId withGroupId:groupID withDisplayName:displayName andViewControllerObject:fromViewController andWithText:preText];
        
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
            self.chatLauncher =[[ALChatLauncher alloc] initWithApplicationId:APPLICATION_ID];
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



+( ALUser * )getLoggedinUserInformation
{
    
    ALUser *user = [[ALUser alloc] init];
    [user setApplicationId:APPLICATION_ID];
    [user setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];      // 3. APP_MODULE_NAME setter
    
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
    
    [ALApplozicSettings setSendMsgTextColor:[UIColor whiteColor]];
    [ALApplozicSettings setReceiveMsgTextColor:[UIColor grayColor]];
    
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    [ALApplozicSettings setNotificationTitle:appName];
    [ALApplozicSettings setMaxCompressionFactor:0.1f];
    [ALApplozicSettings setMaxImageSizeForUploadInMB:3];
    [ALApplozicSettings setMultipleAttachmentMaxLimit:5];  //NSInteger
    [ALApplozicSettings setGroupOption:YES];
    [ALApplozicSettings setChatWallpaperImageName:@"NULL"];
    
    [ALApplozicSettings setGroupExitOption:YES];
    [ALApplozicSettings setGroupMemberAddOption:YES];
    [ALApplozicSettings setGroupMemberRemoveOption:YES];
    
////////////////////////////////////   SET COLOR FOR TOAST  //////////////////////////////////
    
    [ALApplozicSettings setColorForToastText:[UIColor blackColor]];
    [ALApplozicSettings setColorForToastBackground:[UIColor grayColor]];
    
    
//////////////   SET VISIBILITY FOR REFRESH BUTTON (COMES FROM TOP IN MSG VC)   ////////////
    
    [ALApplozicSettings setCustomNavRightButtonMsgVC:NO];
    /*   Note: Please set to 'NO' if NOT REQUIRED */
    
    
//////////////   SET VISIBILITY NO MORE CONVERSATION (COMES FROM TOP IN MSG VC)   ////////////
     [ALApplozicSettings setVisibilityForNoMoreConversationMsgVC:NO];
    
    
//////////////   SET BACK BUTTON FOR MSG VC  ////////////
    
    [ALApplozicSettings setTitleForBackButtonMsgVC:@"Back"];

    
//////////////   SET BACK BUTTON FOR CHAT VC  ////////////
    
    [ALApplozicSettings setTitleForBackButtonChatVC:@"Back"];
    
    
//////////////   SET VISIBILITY FOR ONLINE INDICATOR   ////////////
    
    [ALApplozicSettings setVisibilityForOnlineIndicator:YES];
/*   Note: Please set to YES if required */

//////////////   SET TEXT FOR EMPTY CONVERSATION   //////////////
    
    [ALApplozicSettings setEmptyConversationText:@"You have no conversations yet"];
/* ADD TEXT YOU WANT TO SHOW */
    
//////////////   SET COLOR FOR SEND BUTTON   //////////////
    
    UIColor * sendButtonColor = [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1];
    [ALApplozicSettings setColorForSendButton:sendButtonColor];
/*   Note: COLOR SHOULD BE PRESENT */
    
    
//////////////   SET COLOR FOR TYPE MESSAGE VIEW BUTTON   //////////////

    [ALApplozicSettings setColorForTypeMsgBackground:[UIColor lightGrayColor]];
/*   Note: DEFAULT COLOR LIGHT GRAY */
    

//////////////   SET NO CONVERSATION LABEL IN CHAT VC //////////////
    
    [ALApplozicSettings setVisibilityNoConversationLabelChatVC:YES];

/*   Note: Please set to NO if not required */
    
    
    
//////////////   SET COLOR FOR TYPING LABEL  //////////////

    [ALApplozicSettings setBGColorForTypingLabel:[UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0 alpha:1]];
//    [ALApplozicSettings setBGColorForTypingLabel:[UIColor brownColor]];


//////////////   SET COLOR FOR TEXT TYPING LABEL  //////////////

//    [ALApplozicSettings setTextColorForTypingLabel:[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:0.5]];
    [ALApplozicSettings setTextColorForTypingLabel:[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:0.5]];
    
    
//////////////   IF NOTIFICATION SOUND NOT NEEDED   //////////////
    
    [ALApplozicSettings disableNotificationSound];
/*   Note: Please uncomment above if sound NOT needed */
    
    
//////////////   IF NOTIFICATION SOUND NEEDED   //////////////
    
//    [ALApplozicSettings enableNotificationSound];
/*   Note: Please uncomment above IF NEEDED */
    
    
    [ALApplozicSettings setContextualChat:YES];
    
/*   Note: Please uncomment below setter to use app_module_name */
    
//   [ALUserDefaultsHandler setAppModuleName:@"<APP_MODULE_NAME>"];
//    [ALUserDefaultsHandler setAppModuleName:@"SELLER"];

//////////////   APPLICATION URL CONFIGURATION    //////////////
    
    [self getApplicationBaseURL];
/*   Note: PLEASE DO NOT COMMENT THIS  */
    
    
//////////////   IF NEEDED ALL REGISTERED CONTACTS    //////////////
    
    [ALApplozicSettings setFilterContactsStatus:YES];
/*   PLEASE SET IT TO 'NO' IF NOT REQUIRED */
    
//////////////   IF NEEDED ONLINE USERS WITH LIMIT   //////////////
    
    [ALApplozicSettings setOnlineContactLimit:0];
/*   PLEASE SET LIMIT TO ZERO IF NOT REQUIRED */

//////////////   IF CALL OPTION NEEDED   //////////////
    
    [ALApplozicSettings setCallOption:YES];
/*    PLEASE SET IT TO 'NO' IF NOT REQUIRED      */
    
    
//////////////   SET 3rd Party Class Name OR DemoChatManager   //////////////
    
    [ALApplozicSettings setCustomClassName:@"DemoChatManager"]; // EXAMPLE
    
//////////////   SET MESSAGE LIST PAGE SIZE   //////////////
    
    [ALUserDefaultsHandler setFetchConversationPageSize:20];  // DEFAULT VALUE 20
    
}

-(void)getApplicationBaseURL
{
    NSDictionary * URLDictionary = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"APPLOZIC_PRODUCTION"];

    NSString * alKBASE_URL = [URLDictionary valueForKey:@"AL_KBASE_URL"];
//    NSString * alMQTT_URL = [URLDictionary valueForKey:@"AL_MQTT_URL"];
    NSString * alFILE_URL = [URLDictionary valueForKey:@"AL_FILE_URL"];
    NSString * alMQTT_PORT = [URLDictionary valueForKey:@"AL_MQTT_PORT"];
    
    [ALUserDefaultsHandler setBASEURL:alKBASE_URL];
//    [ALUserDefaultsHandler setMQTTURL:alMQTT_URL];
    [ALUserDefaultsHandler setFILEURL:alFILE_URL];
    [ALUserDefaultsHandler setMQTTPort:alMQTT_PORT];

}

//============================= Launch chat list with specified User's chat screen open ===============================//

-(void)launchListWithUserORGroup: (NSString *)userId ORWithGroupID: (NSNumber *)groupId andFromViewController:(UIViewController*)fromViewController
{
    
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_ID];
    
    //User is already registered ..directly launch the chat...
    if([ALUserDefaultsHandler getDeviceKeyString]){
        
        LaunchChatFromSimpleViewController *lObj=[[LaunchChatFromSimpleViewController alloc] init];
        [lObj.activityView removeFromSuperview];
        
        //Launch
        if(userId || groupId){
            [self.chatLauncher launchChatListWithUserOrGroup:userId withChannel:groupId andViewControllerObject:fromViewController];
            
        }else{
            
            NSString * title = fromViewController.title? fromViewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:fromViewController ];
        }
        return;
    }
    
    //Registartion Reuired....
    ALUser *alUser = DemoChatManager.getLoggedinUserInformation;
    
    if(!alUser){
        NSLog(@"Not able to find user detail for registration...please register with applozic server first");
        return;
    }
    
    [self ALDefaultChatViewSettings];
    
    [alUser setApplicationId:APPLICATION_ID ];
    [alUser setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];  // 4. APP_MODULE_NAME  setter
    
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
        
        //Launch
        if(userId || groupId){
            [self.chatLauncher launchChatListWithUserOrGroup:userId withChannel:groupId andViewControllerObject:fromViewController];
            
        }else{
            
            NSString * title = fromViewController.title? fromViewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:fromViewController ];
        }
        
    }];
}


//====================================================================================//

// DELEGATE FOR THIRD PARTY ACTION ON TAP GESTURE
+(void)handleCustomAction:(UIViewController *)chatView andWithMessage:(ALMessage *)alMessage
{
    NSLog(@"DELEGATE FOR THIRD PARTY ACTION ON TAP GESTURE");
    NSLog(@"ALMESSAGE_META_DATA :: %@",alMessage.metadata);
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    UIViewController * customView = [storyboard instantiateViewControllerWithIdentifier:@"CustomVC"];
//    ALChatViewController * chatVC = (ALChatViewController *)chatView;
//    [chatVC presentViewController:customView animated:YES completion:nil];
}

@end
