//
//  ALChanelUserX.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>

@interface ALChanelUserX : NSObject

@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *latestMessageId;
@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, copy) NSManagedObjectID *channelUserXDBObjectId;

@property (nonatomic) short status;
@property (nonatomic) Byte role;
@property (nonatomic) int unreadCount;

@end
