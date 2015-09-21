//
//  ALParsingHandler.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ALMessage.h"

@interface ALParsingHandler : NSObject

+(ALMessage *) parseMessage:(id) messageJson;

+(NSMutableArray *) parseMessagseArray:(id) messagejson;

+(BOOL) validateJsonClass:(NSDictionary *) jsonClass;


@end
