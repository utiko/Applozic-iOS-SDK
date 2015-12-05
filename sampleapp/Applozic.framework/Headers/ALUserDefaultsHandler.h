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

+(NSString *) getDeviceKeyString;

+(void) setUserId: (NSString *) userId;

+(NSString*)getUserId;

+(void) setLastSyncTime: (NSNumber *) lastSyncTime;

+(NSString *)getLastSyncTime;
+(NSString *)getUserKeyString;
+(NSString *)getDisplayName;
@end
