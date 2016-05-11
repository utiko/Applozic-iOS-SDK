//
//  ALApplozicSettings.h
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#define USER_PROFILE_PROPERTY @"USER_PROFILE_PROPERTY"
#define SEND_MSG_COLOUR @"SEND_MSG_COLOUR"
#define RECEIVE_MSG_COLOUR @"RECEIVE_MSG_COLOUR"
#define NAVIGATION_BAR_COLOUR @"NAVIGATION_BAR_COLOUR"
#define NAVIGATION_BAR_ITEM_COLOUR @"NAVIGATION_BAR_ITEM_COLOUR"
#define REFRESH_BUTTON_VISIBILITY @"REFRESH_BUTTON_VISIBILITY"
#define CONVERSATION_TITLE @"CONVERSATION_TITLE"
#define BACK_BUTTON_TITLE @"BACK_BUTTON_TITLE"
#define FONT_FACE @"FONT_FACE"
#define NOTIFICATION_TITLE @"NOTIFICATION_TITLE"
#define IMAGE_COMPRESSION_FACTOR @"IMAGE_COMPRESSION_FACTOR"
#define IMAGE_UPLOAD_MAX_SIZE @"IMAGE_UPLOAD_MAX_SIZE"
#define GROUP_ENABLE @"GROUP_ENABLE"
#define MAX_SEND_ATTACHMENT @"MAX_SEND_ATTACHMENT"
#define FILTER_CONTACT @"FILTER_CONTACT"
#define FILTER_CONTACT_START_TIME @"FILTER_CONTACT_START_TIME"
#define WALLPAPER_IMAGE @"WALLPAPER_IMAGE"
#define CUSTOM_MSG_BACKGROUND_COLOR @"CUSTOM_MSG_BACKGROUND_COLOR"
#define ONLINE_CONTACT_LIMIT @"ONLINE_CONTACT_LIMIT"
#define GROUP_EXIT_BUTTON @"GROUP_EXIT_BUTTON"
#define GROUP_MEMBER_ADD_OPTION @"GROUP_MEMBER_ADD_OPTION"
#define GROUP_MEMBER_REMOVE_OPTION @"GROUP_MEMBER_REMOVE_OPTION"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALApplozicSettings : NSObject

+(void)setFontFace:(NSString *)fontFace;

+(NSString *)getFontFace;

+(void)setUserProfileHidden: (BOOL)flag;

+(BOOL)isUserProfileHidden;

+(void)setColorForSendMessages:(UIColor *)sendMsgColor ;

+(void)setColorForReceiveMessages:(UIColor *)receiveMsgColor;

+(UIColor *)getSendMsgColor;

+(UIColor *)getReceiveMsgColor;

+(void)setColorForNavigation:(UIColor *)barColor;

+(UIColor *)getColorForNavigation;

+(void)setColorForNavigationItem:(UIColor *)barItemColor;

+(UIColor *)getColorForNavigationItem;

+(void) clearAllSettings;

+(void)hideRefreshButton:(BOOL)state;

+(BOOL)isRefreshButtonHidden;

+(void)setTitleForConversationScreen:(NSString *)titleText;

+(NSString *)getTitleForConversationScreen;

+(void)setTitleForBackButton:(NSString *)backButtonTitle;

+(NSString *)getBackButtonTitle;

+(void)setNotificationTitle:(NSString *)notificationTitle;

+(NSString *)getNotificationTitle;

+(void)setMaxImageSizeForUploadInMB:(NSInteger)maxFileSize;

+(NSInteger)getMaxImageSizeForUploadInMB;

+(void) setMaxCompressionFactor:(double)maxCompressionRatio;

+(double) getMaxCompressionFactor;

+(void)setGroupOption:(BOOL)option;

+(BOOL)getGroupOption;

+(void)setMultipleAttachmentMaxLimit:(NSInteger)limit;

+(NSInteger)getMultipleAttachmentMaxLimit;

+(void)setFilterContactsStatus:(BOOL)flag;

+(BOOL)getFilterContactsStatus;

+(void)setStartTime:(NSNumber *)startTime;

+(NSNumber *)getStartTime;

+(void)setChatWallpaperImageName:(NSString*)imageName;

+(NSString *)getChatWallpaperImageName;

+(void)setCustomMessageBackgroundColor:(UIColor *)color;

+(UIColor *)getCustomMessageBackgroundColor;

+(void)setGroupExitOption:(BOOL)option;
+(BOOL)getGroupExitOption;

+(void)setGroupMemberAddOption:(BOOL)option;
+(BOOL)getGroupMemberAddOption;

+(void)setGroupMemberRemoveOption:(BOOL)option;
+(BOOL)getGroupMemberRemoveOption;

+(void)setOnlineContactLimit:(NSInteger)limit;
+(NSInteger)getOnlineContactLimit;
@end
