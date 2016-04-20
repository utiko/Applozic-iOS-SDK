//
//  DemoChatManager.h
//  applozicdemo
//
//  Created by Devashish on 28/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Applozic/ALChatLauncher.h>
#import <Applozic/ALUser.h>
#import <Applozic/ALConversationService.h>

//#define APPLICATION_ID @"APPLOZIC"
#define APPLICATION_ID @"applozic-sample-app"

/* Note: Please uncomment the following two lines and respective four APP_MODULE_NAME setters in DemoChatManager.m  */

//#define APPLICATION_ID @"cb0b5733c34afeb2bbda42d3653f9f57"
//#define APP_MODULE_NAME @"<MODULE_NAME>"


@interface DemoChatManager : NSObject

@property(nonatomic,strong) ALChatLauncher * chatLauncher;

-(void)registerUser:(ALUser * )alUser;

@property(nonatomic,retain) NSString * userID;

-(void)launchChat: (UIViewController *)fromViewController;

-(void)launchChatForUserWithDefaultText:(NSString * )userId andFromViewController:(UIViewController*)viewController;

-(void)registerUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController*)viewController forUser:(NSString*)userId withGroupId:(NSNumber*)groupID;

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController;

-(void)createAndLaunchChatWithSellerWithConversationProxy:(ALConversationProxy*)alConversationProxy fromViewController:(UIViewController*)fromViewController;

-(void)launchListWithUserORGroup: (NSString *)userId ORWithGroupID: (NSNumber *)groupId andFromViewController:(UIViewController*)fromViewController;

@end
