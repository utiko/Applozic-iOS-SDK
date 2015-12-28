//
//  ALChanelUserMapper.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALChanelUserMapper : NSObject

@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *latestMessageId;

@property short status;
@property Byte role;
@property NSInteger key;
@property int unreadCount;

@end
