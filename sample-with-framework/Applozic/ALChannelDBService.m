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

-(void)insertChannel:(NSMutableArray *)channelList
{
    NSMutableArray *channelArray = [[NSMutableArray alloc] init];
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    for(ALChannel *channel in channelList){
        
        DB_CHANNEL *dbChannel = [self createChannelEntity:channel];
        // IT MIGHT BE USED In FUTURE
        //[theDBHandler.managedObjectContext save:nil];
        //channel.channelDBObjectId = dbChannel.objectID;
        [channelArray addObject:channel];
    }
    
    
    NSError *error = nil;
    [theDBHandler.managedObjectContext save:&error];
    if(error)
    {
        NSLog(@"ERROR IN insertChannel METHOD %@",error);
    }
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
        theChannelEntity.type = channel.type;
        theChannelEntity.adminId = channel.adminKey;
        theChannelEntity.unreadCount = channel.unreadCount;
    }
    
    return theChannelEntity;
}

-(void)insertChannelUserX:(ALChanelUserX *)channelUserX
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL_USER_X *dbChannelUserX = [self createChannelUserXEntity:channelUserX];
    [theDBHandler.managedObjectContext save:nil];
    channelUserX.channelUserXDBObjectId = dbChannelUserX.objectID;
    
    NSError *error = nil;
    [theDBHandler.managedObjectContext save:&error];
    if(error)
    {
        NSLog(@"ERROR IN insertChannelUserX METHOD %@",error);
    }
    
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
    }
    
    return theChannelUserXEntity;
}

@end
