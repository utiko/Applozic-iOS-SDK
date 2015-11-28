//
//  ALApplozicSettings.m
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALApplozicSettings.h"

@interface ALApplozicSettings ()

@end

@implementation ALApplozicSettings

+(void)setUserProfileHidden: (BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:USER_PROILE_PROPERTY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isUserProfileHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:USER_PROILE_PROPERTY];
}

+(void) clearAllSettings
{
    NSLog(@"cleared");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+(void)setColourForSendMessages:(UIColor *)sendMsgColour
{
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sendMsgColour];
    [[NSUserDefaults standardUserDefaults] setObject:sendColorData forKey:SEND_MSG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setColourForReceiveMessages:(UIColor *)receiveMsgColour
{
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receiveMsgColour];
    [[NSUserDefaults standardUserDefaults] setObject:receiveColorData forKey:RECEIVE_MSG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getSendMsgColour
{
    NSData *sendColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"SEND_MSG_COLOUR"];
    UIColor *sendColour = [NSKeyedUnarchiver unarchiveObjectWithData:sendColorData];
    return sendColour;
}

+(UIColor *)getReceiveMsgColour
{
    NSData *receiveColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"RECEIVE_MSG_COLOUR"];
    UIColor *receiveColour = [NSKeyedUnarchiver unarchiveObjectWithData:receiveColorData];
    return receiveColour;
}

+(void)setColourForNavigation:(UIColor *)barColour
{
    NSData *barColourData = [NSKeyedArchiver archivedDataWithRootObject:barColour];
    [[NSUserDefaults standardUserDefaults] setObject:barColourData forKey:NAVIGATION_BAR_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(UIColor *)getColourForNavigation
{
    NSData *barColourData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NAVIGATION_BAR_COLOUR"];
    UIColor *barColour = [NSKeyedUnarchiver unarchiveObjectWithData:barColourData];
    return barColour;
}

+(void)setColourForNavigationItem:(UIColor *)barItemColour
{
    NSData *barItemColourData = [NSKeyedArchiver archivedDataWithRootObject:barItemColour];
    [[NSUserDefaults standardUserDefaults] setObject:barItemColourData forKey:NAVIGATION_BAR_ITEM_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(UIColor *)getColourForNavigationItem
{
    NSData *barItemColourData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NAVIGATION_BAR_ITEM_COLOUR"];
    UIColor *barItemColour = [NSKeyedUnarchiver unarchiveObjectWithData:barItemColourData];
    return barItemColour;
}

@end
