//
//  ALUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUserDefaultsHandler.h"

@implementation ALUserDefaultsHandler

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

@end
