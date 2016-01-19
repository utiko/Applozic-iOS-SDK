//
//  ALUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUserDefaultsHandler.h"

@implementation ALUserDefaultsHandler

+(void) setConversationContactImageVisibility:(BOOL)visibility{
    [[NSUserDefaults standardUserDefaults] setBool:visibility forKey:CONVERSATION_CONTACT_IMAGE_VISIBILITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isConversationContactImageVisible {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONVERSATION_CONTACT_IMAGE_VISIBILITY];
}

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
   lstSyncTime = @([lstSyncTime doubleValue]);
    NSLog(@"saving last Sync time in the preference ...%@" ,lstSyncTime);
    [[NSUserDefaults standardUserDefaults] setDouble:[lstSyncTime doubleValue] forKey:LAST_SYNC_TIME];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getLastSyncTime{
    
   // NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    return [[NSUserDefaults standardUserDefaults] valueForKey:LAST_SYNC_TIME];
}


+(void)setServerCallDoneForMSGList:(BOOL) value forContactId:(NSString*)contactId{
    if(!contactId){
        return;
    }
    NSString *key = [ contactId stringByAppendingString:MSG_LIST_CALL_SUFIX];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(BOOL)isServerCallDoneForMSGList: (NSString *)contactId{
    
    if(!contactId){
        return NO;
    }
    NSString *key = [ contactId stringByAppendingString:MSG_LIST_CALL_SUFIX];
    if ( ![[NSUserDefaults standardUserDefaults] valueForKey:key] ){
        return NO;
    }else{
        return [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }
    
}


+(void) setProcessedNotificationIds:(NSMutableArray*) arrayWithIds{

    [[NSUserDefaults standardUserDefaults] setObject:arrayWithIds forKey:PROCESSED_NOTIFICATION_IDS];

}


+(NSMutableArray*) getProcessedNotificationIds{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"PROCESSED_NOTIFICATION_IDS"] mutableCopy];

}

+(BOOL)isNotificationProcessd:(NSString*)withNotificationId{
   
    NSMutableArray * mutableArray = [ self getProcessedNotificationIds];
    if(mutableArray ==nil){
        mutableArray = [[NSMutableArray alloc]init];
    }
    
    BOOL isTheObjectThere = [mutableArray containsObject:withNotificationId];
    
    if ( isTheObjectThere ){
        //[mutableArray removeObject:withNotificationId];
    }else {
        [mutableArray addObject:withNotificationId];
    }
    //WE will just store 20 notificationIds for processing...
    if(mutableArray.count > 20){
        [ mutableArray removeObjectAtIndex:0];
    }
    [self setProcessedNotificationIds:mutableArray];
    return isTheObjectThere;
    
}

+(void) setLastSeenSyncTime :(NSNumber*) lastSeenTime{
    
    NSLog(@"saving last seen time in the preference ...%@" ,lastSeenTime);
    [[NSUserDefaults standardUserDefaults] setDouble:[lastSeenTime doubleValue] forKey:LAST_SEEN_SYNC_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *) getLastSeenSyncTime{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SEEN_SYNC_TIME];

}

+(void)setShowLoadMore:(BOOL) value forContactId:(NSString*)contactId{
   
    if(!contactId){
        return;
    }
    NSString *key = [ contactId stringByAppendingString:SHOW_LOAD_MORE_BUTTON];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

+(BOOL)isShowLoadMore:(NSString *) contactId{
   
    if(!contactId){
        return NO;
    }
    NSString *key = [ contactId stringByAppendingString:SHOW_LOAD_MORE_BUTTON];
    if ( ![[NSUserDefaults standardUserDefaults] valueForKey:key] ){
        return YES;
    }else{
        return [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }

}
//Notification settings...

+(void)setNotificationTitle:(NSString *)notificationTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:notificationTitle forKey:NOTIFICATION_TITLE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getNotificationTitle{
    return [[NSUserDefaults standardUserDefaults] valueForKey:NOTIFICATION_TITLE];
}

@end
