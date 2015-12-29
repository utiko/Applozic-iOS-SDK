//
//  ALChannelDBService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannelDBService.h"

@interface ALChannelDBService ()

@end

@implementation ALChannelDBService

-(void)insertChannel:(ALChannel *)channel
{
//    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
//    DB_CHANNEL *dbChannel = [self createChannel:channel];
//    [theDBHandler.managedObjectContext save:nil];
//    channel.channelDBObjectId = dbChannel.objectID;
//    [theDBHandler.managedObjectContext save:nil];
}

-(DB_CHANNEL *)createChannelEntity:(ALChannel *)channel
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL * theChannelEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CHANNEL" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    if(channel)
    {
        theChannelEntity.channelDisplayName = channel.name;
        theChannelEntity.channelKey = channel.key;
        theChannelEntity.userCount = channel.userCount;
        theChannelEntity.createdAt = channel.createdAt;
        theChannelEntity.type = channel.type;
        theChannelEntity.messageSize = channel.mesgSize;
        theChannelEntity.messageCount = channel.mesgCount;
        theChannelEntity.updatedAt = channel.updatedAt;
    }
    
    return theChannelEntity;
}

-(void)insertChannelUserX:(ALChanelUserX *)channelUserX
{
//    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
//    DB_CHANNEL_USER_X *dbChannelUserX = [self createChannelUserX:channelUserX];
//    [theDBHandler.managedObjectContext save:nil];
//    channelUserMapper.channelUserXDBObjectId = dbChannelUserX.objectID;
//    [theDBHandler.managedObjectContext save:nil];
    
}

-(DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChanelUserX *)channelUserX
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL_USER_X * theChannelUserXEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    if(channelUserX)
    {
        theChannelUserXEntity.channelKey = channelUserX.key;
        theChannelUserXEntity.userId = channelUserX.userKey;
        theChannelUserXEntity.status = channelUserX.status;
        theChannelUserXEntity.latestMessageId = channelUserX.latestMessageId;
        theChannelUserXEntity.unreadCount = channelUserX.unreadCount;
    }
    
    return theChannelUserXEntity;
}

@end
