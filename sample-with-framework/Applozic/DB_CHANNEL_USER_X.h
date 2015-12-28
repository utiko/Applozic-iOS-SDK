//
//  DB_CHANNEL_USER_X.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL_USER_X : NSManagedObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *channelKey;
@property (nonatomic, strong) NSString *latestMessageId;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *unreadCount;
@property (nonatomic, strong) NSString *userId;

@end
