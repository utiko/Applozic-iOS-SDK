//
//  ALUserDefaultsHandler.h
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define APPLICATION_KEY @"APPLICATION_KEY"
#define EMAIL_VERIFIED @"EMAIL_VERIFIED"
#define DISPLAY_NAME @"DISPLAY_NAME"
#define DEVICE_KEY_STRING @"DEVICE_KEY_STRING"
#define USER_KEY_STRING @"USER_KEY_STRING"
#define EMAIL_ID @"EMAIL_ID"
#define USER_ID @"USER_ID"
#define APN_DEVICE_TOKEN @"APN_DEVICE_TOKEN"
#define LAST_SYNC_TIME @"LAST_SYNC_TIME"
#define CONVERSATION_DB_SYNCED @"CONVERSATION_DB_SYNCED"
#define LOGOUT_BUTTON_VISIBLITY @"LOGOUT_BUTTON_VISIBLITY"
#define BOTTOM_TAB_BAR_VISIBLITY @"BOTTOM_TAB_BAR_VISIBLITY"
#define BACK_BTN_VISIBILITY_ON_CON_LIST @"BACK_BTN_VISIBILITY_ON_CON_LIST"
#define CONVERSATION_CONTACT_IMAGE_VISIBILITY @"CONVERSATION_CONTACT_IMAGE_VISIBILITY"
#define MSG_LIST_CALL_SUFIX @":MSG_CALL_MADE"
#define PROCESSED_NOTIFICATION_IDS  @"PROCESSED_NOTIFICATION_IDS"
#define LAST_SEEN_SYNC_TIME @"LAST_SEEN_SYNC_TIME"
#define SHOW_LOAD_ERLIER_MESSAGE @":SHOW_LOAD_ERLIER_MESSAGE"
#define LAST_SYNC_CHANNEL_TIME @"LAST_SYNC_CHANNEL_TIME"
#define USER_BLOCK_LAST_TIMESTAMP @"USER_BLOCK_LAST_TIMESTAMP"
#define APP_MODULE_NAME_ID @"APP_MODULE_NAME_ID"
#define CONTACT_VIEW_LOADED @"CONTACT_VIEW_LOADED"
#define USER_INFO_API_CALLED_SUFFIX @":USER_INFO_API_CALLED"
#define APPLOZIC_BASE_URL @"APPLOZIC_BASE_URL"
#define APPLOZIC_MQTT_URL @"APPLOZIC_MQTT_URL"
#define APPLOZIC_FILE_URL @"APPLOZIC_FILE_URL"
#define APPLOZIC_MQTT_PORT @"APPLOZIC_MQTT_PORT"
#define USER_TYPE_ID @"USER_TYPE_ID"
#define MESSSAGE_LIST_LAST_TIME @"MESSSAGE_LIST_LAST_TIME"
#define ALL_CONVERSATION_FETCHED @"ALL_CONVERSATION_FETCHED"
#define CONVERSATION_FETCH_PAGE_SIZE @"CONVERSATION_FETCH_PAGE_SIZE"
#define NOTIFICATION_MODE @"NOTIFICATION_MODE"
#define USER_PASSWORD @"USER_PASSWORD"
#define USER_AUTHENTICATION_TYPE_ID @"USER_AUTHENTICATION_TYPE_ID"

#import <Foundation/Foundation.h>

@interface ALUserDefaultsHandler : NSObject

+(void) setConversationContactImageVisibility: (BOOL) visibility;

+(BOOL) isConversationContactImageVisible;

+(void) setBottomTabBarHidden: (BOOL) visibleStatus;

+(BOOL) isBottomTabBarHidden;

+(void) setLogoutButtonHidden: (BOOL)flagValue;

+(BOOL) isLogoutButtonHidden;

+(void) setBackButtonHidden: (BOOL)flagValue;

+(BOOL) isBackButtonHidden;

+(BOOL) isLoggedIn;

+(void) clearAll;

+(NSString *) getApplicationKey;

+(void) setApplicationKey: (NSString*) applicationKey;

+(void) setEmailVerified: (BOOL) value;

+(void) setApnDeviceToken: (NSString*) apnDeviceToken;

+(NSString *) getApnDeviceToken;

+(void) setBoolForKey_isConversationDbSynced:(BOOL) value;

+(BOOL) getBoolForKey_isConversationDbSynced;

+(void) setDeviceKeyString:(NSString*)deviceKeyString;

+(void) setUserKeyString:(NSString*)userKeyString;

+(void) setDisplayName:(NSString*)displayName;

+(void) setEmailId:(NSString*)emailId;

+(NSString *)getEmailId;

+(NSString *) getDeviceKeyString;

+(void) setUserId: (NSString *) userId;

+(NSString*)getUserId;

+(void) setLastSyncTime: (NSNumber *) lastSyncTime;

+(void)setServerCallDoneForMSGList:(BOOL) value forContactId:(NSString*)constactId;

+(BOOL)isServerCallDoneForMSGList:(NSString *) contactId;

+(void) setProcessedNotificationIds:(NSMutableArray*) arrayWithIds;

+(NSMutableArray*) getProcessedNotificationIds;

+(BOOL)isNotificationProcessd:(NSString*)withNotificationId;

+(NSNumber *) getLastSeenSyncTime;

+(void) setLastSeenSyncTime :(NSNumber*) lastSeenTime;

+(void) setShowLoadEarlierOption : (BOOL) value forContactId:(NSString*)constactId;

+(BOOL)isShowLoadEarlierOption :(NSString*)constactId;

+(void)setLastSyncChannelTime:(NSNumber *)lastSyncChannelTime;

+(NSNumber *)getLastSyncChannelTime;

+(NSNumber *)getLastSyncTime;

+(NSString *)getUserKeyString;

+(NSString *)getDisplayName;

+(void)setUserBlockLastTimeStamp:(NSNumber *)lastTimeStamp;

+(NSNumber *)getUserBlockLastTimeStamp;

//+(NSString *)getNotificationTitle;
//+(void)setNotificationTitle:(NSString *)notificationTitle;

+(NSString *)getPassword;
+(void )setPassword:(NSString *)password;

+(void)setAppModuleName:(NSString*)appModuleName;
+(NSString*)getAppModuleName;

+(BOOL) getContactViewLoaded;
+(void) setContactViewLoadStatus:(BOOL)status;

+(void)setServerCallDoneForUserInfo:(BOOL)value ForContact:(NSString*)contactId;
+(BOOL)isServerCallDoneForUserInfoForContact:(NSString*)contactId;

+(void)setBASEURL:(NSString *)baseURL;
+(NSString *)getBASEURL;

+(void)setMQTTURL:(NSString *)mqttURL;
+(NSString *)getMQTTURL;

+(void)setFILEURL:(NSString *)fileURL;
+(NSString *)getFILEURL;

+(void)setMQTTPort:(NSString *)portNumber;
+(NSString *)getMQTTPort;

+(void)setUserTypeId:(short)type;
+(short)getUserTypeId;

+(NSNumber *)getLastMessageListTime;
+(void)setLastMessageListTime:(NSNumber *)lastTime;

+(BOOL)getFlagForAllConversationFetched;
+(void)setFlagForAllConversationFetched:(BOOL)flag;

+(NSInteger)getFetchConversationPageSize;
+(void)setFetchConversationPageSize:(NSInteger)limit;

+(short)getNotificationMode;
+(void)setNotificationMode:(short)mode;

+(short)getUserAuthenticationTypeId;
+(void)setUserAuthenticationTypeId:(short)type;

@end
