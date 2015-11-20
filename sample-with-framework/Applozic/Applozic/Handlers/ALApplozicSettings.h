//
//  ALApplozicSettings.h
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#define USER_PROILE_PROPERTY @"USER_PROILE_PROPERTY"

#import <Foundation/Foundation.h>


@interface ALApplozicSettings : NSObject

+(void)setUserProfileHidden: (BOOL)flag;

+(BOOL)isUserProfileHidden;

+(void) clearAllSettings;

@end
