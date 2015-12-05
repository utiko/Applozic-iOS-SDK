//
//  ALUserDetail.h
//  Applozic
//
//  Created by devashish on 26/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface ALUserDetail : ALJson


@property NSString *userId;

@property NSString *connected;

@property NSString *lastSeenAtTime;

@property NSString *unreadCount;

-(void)setUserDetails:(NSString *)jsonString;

-(void)userDetail;

@end
