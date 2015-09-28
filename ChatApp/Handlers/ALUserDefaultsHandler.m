//
//  ALUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUserDefaultsHandler.h"

@implementation ALUserDefaultsHandler

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

+(void )setLastSyncTime :( NSString *) lstSyncTime
{
    [[NSUserDefaults standardUserDefaults] setValue:lstSyncTime forKey:LAST_SYNC_TIME];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getLastSyncTime{
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:LAST_SYNC_TIME];
}

@end
