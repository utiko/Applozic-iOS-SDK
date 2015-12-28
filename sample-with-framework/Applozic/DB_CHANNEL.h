//
//  DB_CHANNEL.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL : NSManagedObject

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *channelDisplayName;
@property (nonatomic, strong) NSString *channelKey;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *messageCount;
@property (nonatomic, strong) NSString *messageSize;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *userCount;

@end
