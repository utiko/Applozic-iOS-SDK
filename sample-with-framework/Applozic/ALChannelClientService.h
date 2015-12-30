//
//  ALChannelClientService.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  class for server calls

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALChannel.h"
#import "ALChannelUserX.h"
#import "ALChannelDBService.h"

@interface ALChannelClientService : NSObject

+(void)serverCallForChannelCreation:(NSString *)channelId;
+(void)serverCallForChannelList:(NSString *)channelId;
+(void)serverCallForDeleteChannel:(NSString *)channelId;
+(void)serverCallForRemoveMemberFromChannel:(NSString *)channelId;
+(void)serverCallForLeaveMemberFromChannel:(NSString *)channelId;

+(void)getChannelArray:(NSMutableArray *) channelArray;

@end
