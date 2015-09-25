//
//  ALUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUserDefaultsHandler.h"

@implementation ALUserDefaultsHandler

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

+(void) setEmailVerified:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:EMAIL_VERIFIED];
}

+(void) getEmailVerified:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] boolForKey: EMAIL_VERIFIED];
}

// isConversationDbSynced

+(void)setBoolForKey_isConversationDbSynced:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"isConversationDbSynced"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getBoolForKey_isConversationDbSynced
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isConversationDbSynced"];
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

+(NSString *)getUserKeyString{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_KEY_STRING];
}

//user Id
+(void )setUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:@"USER_ID"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(NSString *)getUserId
{
    return [[NSUserDefaults standardUserDefaults]
            valueForKey:@"USER_ID"];
}

//last sync time

+(void )setLastSyncTime :( NSString *) lstSyncTime
{
    [[NSUserDefaults standardUserDefaults] setValue:lstSyncTime forKey:@"LAST_SYNC_TIME"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getLastSyncTime{
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"LAST_SYNC_TIME"];
}

@end
