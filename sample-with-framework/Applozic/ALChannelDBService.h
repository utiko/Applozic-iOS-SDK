//
//  ALChannelDBService.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  class for databse actios for group

#import <Foundation/Foundation.h>
#import "ALChannel.h"
#import "DB_CHANNEL.h"
#import "DB_CHANNEL_USER_X.h"
#import "ALDBHandler.h"
#import "ALChannelUserX.h"

@interface ALChannelDBService : NSObject

-(void)insertChannel:(NSMutableArray *)channelList;
-(DB_CHANNEL *) createChannelEntity:(ALChannel *)channel;
-(void)insertChannelUserX:(NSMutableArray *)channelUserX;
-(DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserXList;

@end
