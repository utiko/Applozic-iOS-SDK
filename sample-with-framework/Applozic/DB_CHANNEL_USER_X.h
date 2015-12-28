//
//  DB_CHANNEL_USER_X.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL_USER_X : NSManagedObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *channelKey;
@property (nonatomic, retain) NSString *latestMessageId;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *unreadCount;
@property (nonatomic, retain) NSString *userId;

@end
