//
//  DB_CHANNEL.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL : NSManagedObject

@property (nonatomic, retain) NSString *applicationId;
@property (nonatomic, retain) NSString *channelDisplayName;
@property (nonatomic, retain) NSString *channelKey;
@property (nonatomic, retain) NSString *createdAt;
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *messageCount;
@property (nonatomic, retain) NSString *messageSize;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *updatedAt;
@property (nonatomic, retain) NSString *userCount;

@end
