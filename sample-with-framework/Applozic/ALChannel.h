//
//  ALChannel.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  this clss will decide wether go client or groupdb service

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "ALJson.h"

typedef enum
{
    VIRTUAL,
    PRIVATE,
    PUBLIC,
    SELLER,
    SELF
} GroupType;

@interface ALChannel : ALJson

@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *adminKey;
@property (nonatomic) short type;
@property (nonatomic) int userCount;
@property (nonatomic) int unreadCount;
@property (nonatomic, copy) NSManagedObjectID *channelDBObjectId;
@property (nonatomic, strong) NSMutableArray *membersName;

-(id)initWithDictonary:(NSDictionary *)messageDictonary;
-(void)parseMessage:(id) messageJson;

@end
