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

+(void)setFontFace:(NSString *)fontFace
{
    [[NSUserDefaults standardUserDefaults] setValue:fontFace forKey:FONT_FACE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getFontFace
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:FONT_FACE];
}

+(void)setTitleForConversationScreen:(NSString *)titleText
{
    [[NSUserDefaults standardUserDefaults] setValue:titleText forKey:CONVERSATION_TITLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTitleForConversationScreen
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:CONVERSATION_TITLE];
}

+(void)setUserProfileHidden: (BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:USER_PROFILE_PROPERTY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isUserProfileHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:USER_PROFILE_PROPERTY];
}

+(void) clearAllSettings
{
    NSLog(@"cleared");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+(void)setColorForSendMessages:(UIColor *)sendMsgColor
{
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sendMsgColor];
    [[NSUserDefaults standardUserDefaults] setObject:sendColorData forKey:SEND_MSG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setColorForReceiveMessages:(UIColor *)receiveMsgColor
{
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receiveMsgColor];
    [[NSUserDefaults standardUserDefaults] setObject:receiveColorData forKey:RECEIVE_MSG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getSendMsgColor
{
    NSData *sendColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"SEND_MSG_COLOUR"];
    UIColor *sendColor = [NSKeyedUnarchiver unarchiveObjectWithData:sendColorData];
    if(sendColor)
    {
        return sendColor;
    }
    return [UIColor whiteColor];
}

+(UIColor *)getReceiveMsgColor
{
    NSData *receiveColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"RECEIVE_MSG_COLOUR"];
    UIColor *receiveColor = [NSKeyedUnarchiver unarchiveObjectWithData:receiveColorData];
    if(receiveColor)
    {
        return receiveColor;
    }
    return [UIColor whiteColor];
}

+(void)setColorForNavigation:(UIColor *)barColor
{
    NSData *barColorData = [NSKeyedArchiver archivedDataWithRootObject:barColor];
    [[NSUserDefaults standardUserDefaults] setObject:barColorData forKey:NAVIGATION_BAR_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(UIColor *)getColorForNavigation
{
    NSData *barColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NAVIGATION_BAR_COLOUR"];
    UIColor *barColor = [NSKeyedUnarchiver unarchiveObjectWithData:barColorData];
    return barColor;
}

+(void)setColorForNavigationItem:(UIColor *)barItemColor
{
    NSData *barItemColorData = [NSKeyedArchiver archivedDataWithRootObject:barItemColor];
    [[NSUserDefaults standardUserDefaults] setObject:barItemColorData forKey:NAVIGATION_BAR_ITEM_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(UIColor *)getColorForNavigationItem
{
    NSData *barItemColourData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NAVIGATION_BAR_ITEM_COLOUR"];
    UIColor *barItemColour = [NSKeyedUnarchiver unarchiveObjectWithData:barItemColourData];
    return barItemColour;
}

+(void)hideRefreshButton:(BOOL)state
{
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:REFRESH_BUTTON_VISIBILITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isRefreshButtonHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:REFRESH_BUTTON_VISIBILITY];
}

+(void)setTitleForBackButton:(NSString *)backButtonTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:backButtonTitle forKey:BACK_BUTTON_TITLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getBackButtonTitle
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:BACK_BUTTON_TITLE];
}

+(void)setNotificationTitle:(NSString *)notificationTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:notificationTitle forKey:NOTIFICATION_TITLE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getNotificationTitle{
    return [[NSUserDefaults standardUserDefaults] valueForKey:NOTIFICATION_TITLE];
}

+(void)setMaxImageSizeForUploadInMB:(NSInteger)maxFileSize{
    [[NSUserDefaults standardUserDefaults] setInteger:maxFileSize forKey:IMAGE_UPLOAD_MAX_SIZE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getMaxImageSizeForUploadInMB{
    return [[NSUserDefaults standardUserDefaults] integerForKey:IMAGE_UPLOAD_MAX_SIZE];
    
}

+(void) setMaxCompressionFactor:(double)maxCompressionRatio{
    [[NSUserDefaults standardUserDefaults] setDouble:maxCompressionRatio  forKey:IMAGE_COMPRESSION_FACTOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(double) getMaxCompressionFactor{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:IMAGE_COMPRESSION_FACTOR];
    
}

+(void)setGroupOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_ENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_ENABLE];
}

+(void)setMultipleAttachmentMaxLimit:(NSInteger)limit
{
    [[NSUserDefaults standardUserDefaults] setInteger:limit forKey:MAX_SEND_ATTACHMENT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getMultipleAttachmentMaxLimit
{
    NSInteger maxLimit = [[NSUserDefaults standardUserDefaults] integerForKey:MAX_SEND_ATTACHMENT];
    return maxLimit ? maxLimit : 5;
}

+(void)setFilterContactsStatus:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:FILTER_CONTACT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getFilterContactsStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTACT];
}

+(void)setStartTime:(NSNumber *)startTime
{
    startTime = @([startTime doubleValue] + 1);
    [[NSUserDefaults standardUserDefaults] setDouble:[startTime doubleValue] forKey:FILTER_CONTACT_START_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getStartTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:FILTER_CONTACT_START_TIME];
}

+(void)setChatWallpaperImageName:(NSString*)imageName{
    [[NSUserDefaults standardUserDefaults] setValue:imageName forKey:WALLPAPER_IMAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getChatWallpaperImageName{
    return [[NSUserDefaults standardUserDefaults] valueForKey:WALLPAPER_IMAGE];
}

+(void)setGroupExitOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_EXIT_BUTTON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupExitOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_EXIT_BUTTON];
}

+(void)setGroupMemeberAddOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_MEMBER_ADD_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupMemeberAddOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_MEMBER_ADD_OPTION];
}

+(void)setGroupMemeberRemoveOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_MEMBER_REMOVE_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupMemeberRemoveOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_MEMBER_REMOVE_OPTION];
}

@end
