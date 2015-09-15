//
//  ALUserDefaultsHandler.h
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALUserDefaultsHandler : NSObject

+(void) setBoolForKey_isConversationDbSynced:(BOOL ) value;

+(BOOL) getBoolForKey_isConversationDbSynced;

@end
