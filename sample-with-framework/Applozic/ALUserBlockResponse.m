//
//  ALUserBlockResponse.m
//  Applozic
//
//  Created by devashish on 07/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALUserBlockResponse.h"

@implementation ALUserBlockResponse

-(instancetype)initWithJSONString:(NSString *)JSONString
{
    self = [super initWithJSONString:JSONString];
    self.blockedUserList = [NSMutableArray new];
    NSDictionary *JSONDictionary = [JSONString valueForKey:@"blockedUserList"];
    self.blockedToUserList = [[NSMutableArray alloc] initWithArray: [JSONDictionary valueForKey:@"blockedToUserList"]];

    for (NSDictionary *dict in self.blockedToUserList)
    {
        ALUserBlocked *userBlocked = [[ALUserBlocked alloc] init];
        
//            userBlocked.id = [dict valueForKey:@"id"];
//            userBlocked.blockedBy = [dict valueForKey:@"blockedBy"];
        
        userBlocked.blockedTo = [dict valueForKey:@"blockedTo"];
        userBlocked.applicationKey = [dict valueForKey:@"applicationKey"];
        userBlocked.blockedAtTime = [dict valueForKey:@"blockedAtTime"];
        
        [self.blockedUserList addObject:userBlocked];
    }
    
    return self;
}

@end
