//
//  ALUserBlockResponse.h
//  Applozic
//
//  Created by devashish on 07/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#define RESPONSE_SUCCESS @"success"

#import <Applozic/Applozic.h>
#import "ALUserBlocked.h"

@interface ALUserBlockResponse : ALAPIResponse

@property(nonatomic, strong) NSMutableArray * blockedToUserList;

@property(nonatomic, strong) NSMutableArray <ALUserBlocked *> * blockedUserList;

-(instancetype)initWithJSONString:(NSString *)JSONString;

@end
