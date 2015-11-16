//
//  ALUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUserDefaultsHandler.h"

@implementation ALUserDefaultsHandler

+(void) setBottomTabBarHidden:(BOOL)visibleStatus {
    [[NSUserDefaults standardUserDefaults] setBool:visibleStatus forKey:BOTTOM_TAB_BAR_VISIBLITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isBottomTabBarHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:BOTTOM_TAB_BAR_VISIBLITY];
}

+(void) setLogoutButtonHidden:(BOOL)flagValue
{
    [[NSUserDefaults standardUserDefaults] setBool:flagValue forKey:LOGOUT_BUTTON_VISIBLITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isLogoutButtonHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LOGOUT_BUTTON_VISIBLITY];
}

+(void) setBackButtonHidden:(BOOL)flagValue
{
    [[NSUserDefaults standardUserDefaults] setBool:flagValue forKey:BACK_BTN_VISIBILITY_ON_CON_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isBackButtonHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:BACK_BTN_VISIBILITY_ON_CON_LIST];
}

+(void) setApplicationKey:(NSString *)applicationKey
{
    [[NSUserDefaults standardUserDefaults] setValue:applicationKey forKey:APPLICATION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *) getApplicationKey
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:APPLICATION_KEY];
}

+(BOOL) isLoggedIn
{
    return [ALUserDefaultsHandler getDeviceKeyString] != nil;
}

+(void) clearAll
{
    NSLog(@"cleared");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+(void) setApnDeviceToken:(NSString *)apnDeviceToken
{
    [[NSUserDefaults standardUserDefaults] setValue:apnDeviceToken forKey:APN_DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*) getApnDeviceToken
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:APN_DEVICE_TOKEN];
}

+(void) setEmailVerified:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:EMAIL_VERIFIED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void) getEmailVerified
{
    [[NSUserDefaults standardUserDefaults] boolForKey: EMAIL_VERIFIED];
}

// isConversationDbSynced

+(void)setBoolForKey_isConversationDbSynced:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:CONVERSATION_DB_SYNCED];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getBoolForKey_isConversationDbSynced
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONVERSATION_DB_SYNCED];
}

+(void)setEmailId:(NSString *)emailId
{
    [[NSUserDefaults standardUserDefaults] setValue:emailId forKey:EMAIL_ID];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getEmailId{
    return [[NSUserDefaults standardUserDefaults] valueForKey:EMAIL_ID];
}
    

+(void)setDisplayName:(NSString *)displayName
{
    [[NSUserDefaults standardUserDefaults] setValue:displayName forKey:DISPLAY_NAME];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getDisplayName{
    return [[NSUserDefaults standardUserDefaults] valueForKey:DISPLAY_NAME];
}


//deviceKey String
+(void)setDeviceKeyString:(NSString *)deviceKeyString
{
    [[NSUserDefaults standardUserDefaults] setValue:deviceKeyString forKey:DEVICE_KEY_STRING];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getDeviceKeyString{
    return [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_KEY_STRING];
}

+(void)setUserKeyString:(NSString *)suUserKeyString
{
    [[NSUserDefaults standardUserDefaults] setValue:suUserKeyString forKey:USER_KEY_STRING];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getUserKeyString
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_KEY_STRING];
}

//user Id
+(void )setUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:USER_ID];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(NSString *)getUserId
{
    return [[NSUserDefaults standardUserDefaults]
            valueForKey:USER_ID];
}

//last sync time

+(void )setLastSyncTime :( NSNumber *) lstSyncTime
{
   lstSyncTime = @([lstSyncTime doubleValue] + 1);
    NSLog(@"saving last Sync time in the preference ...%@" ,lstSyncTime);
    [[NSUserDefaults standardUserDefaults] setDouble:[lstSyncTime doubleValue] forKey:LAST_SYNC_TIME];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getLastSyncTime{
    
   // NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    return [[NSUserDefaults standardUserDefaults] valueForKey:LAST_SYNC_TIME];
}

@end
