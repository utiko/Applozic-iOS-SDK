//
//  ALGroupDBService.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  class for databse actios for group

#import <Foundation/Foundation.h>

@interface ALGroupDBService : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *channelKey;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *userCount;
@property (nonatomic, strong) NSString *messageSize;
@property (nonatomic, strong) NSString *messageCount;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *unreadCount;
@property (nonatomic, strong) NSString *key;

@end
