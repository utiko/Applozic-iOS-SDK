//
//  ApplozicSettings.m
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ApplozicSettings.h"

@interface ApplozicSettings ()

@end

@implementation ApplozicSettings

+(void)setUserProfileHidden: (BOOL)flag{

    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:USER_PROILE_PROPERTY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isUserProfileHidden{
    return [[NSUserDefaults standardUserDefaults] boolForKey:USER_PROILE_PROPERTY];
}

+(void) clearAllSettings
{
    NSLog(@"cleared");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
