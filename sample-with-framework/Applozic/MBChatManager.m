//
//  MBChatManager.m
//  Applozic
//
//  Created by devashish on 21/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "MBChatManager.h"
#import "ALUserDefaultsHandler.h"
#import "ALApplozicSettings.h"
#import "ALChatViewController.h"

@interface MBChatManager ()

@end

@implementation MBChatManager

-(void)mbChatViewSettings
{
    [ALUserDefaultsHandler setLogoutButtonHidden:YES];
    [ALUserDefaultsHandler setBottomTabBarHidden:YES];
    [ALApplozicSettings setUserProfileHidden:YES];
    [ALApplozicSettings hideRefreshButton:YES];
    [ALApplozicSettings setTitleForConversationScreen:@"My Chats"];
    [ALApplozicSettings setFontFace:@"Helvetica"];
    [ALApplozicSettings setColourForReceiveMessages:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1]];
    [ALApplozicSettings setColourForSendMessages:[UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
    
    [ALApplozicSettings setColourForNavigation:[UIColor colorWithRed:179.0/255 green:32.0/255 blue:35.0/255 alpha:1]];
    [ALApplozicSettings setColourForNavigationItem:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1]];
}

-(void)launchIndividualChat:(NSString *)userId andViewControllerObject:(UIViewController *)viewController;
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALChatViewController *chatView =(ALChatViewController*) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    chatView.contactIds = userId;
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:chatView];
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    
}

-(void)launchChatList:(NSString *)userId andWithBackButtonTitle:(NSString *)title andViewControllerObject:(UIViewController *)viewController
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
    [viewController presentViewController:theTabBar animated:YES completion:nil];
    [ALApplozicSettings setTitleForBackButton:title];
}

@end
