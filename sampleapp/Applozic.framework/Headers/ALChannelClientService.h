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
#import "ALChannelFeed.h"

@interface ALChannelClientService : NSObject

+(void)getChannelArray:(NSMutableArray *) channelArray withCompletion:(void(^)(BOOL flag, NSMutableArray *array)) completion;
+(void)getChannelInfo:(NSNumber *)channelKey withCompletion:(void(^)(NSMutableArray * arrayList, BOOL status, ALChannel *channel)) completion;
@end
