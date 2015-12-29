//
//  ALChannel.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  this clss will decide wether go client or groupdb service

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>

typedef enum
{
    VIRTUAL,
    PRIVATE,
    PUBLIC,
    SELLER,
    SELF
} GroupType;

@interface ALChannel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *adminKey;
@property (nonatomic, strong) NSString *applicationKey;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, copy) NSManagedObjectID * channelDBObjectId;

@property (nonatomic) long updatedAt;
@property (nonatomic) long *createdAt;
@property (nonatomic) long groupId;
@property (nonatomic) long mesgSize;
@property (nonatomic) int userCount;
@property (nonatomic) int mesgCount;
@property (nonatomic) short type;

@end
