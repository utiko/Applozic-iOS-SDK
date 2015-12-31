//
//  DB_CHANNEL.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL : NSManagedObject

@property (nonatomic, retain) NSString *adminId;
@property (nonatomic, retain) NSString *channelDisplayName;
@property (nonatomic, retain) NSNumber *channelKey;
@property (nonatomic) short type;
@property (nonatomic) int userCount;
@property (nonatomic) int unreadCount;
@end
