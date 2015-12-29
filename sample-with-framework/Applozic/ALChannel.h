//
//  ALChannel.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  this clss will decide wether go client or groupdb service

#import <Foundation/Foundation.h>

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
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *applicationKey;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSDate *updatedAt;

@property long groupId;
@property long mesgSize;
@property NSInteger key;
@property int userCount;
@property int mesgCount;
@property short type;

@end
