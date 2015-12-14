//
//  ALUserDetail.m
//  Applozic
//
//  Created by devashish on 26/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALUserDetail.h"

@interface ALUserDetail ()

@end

@implementation ALUserDetail

- (id)initWithJSONString:(NSString *)JSONResponse {
    
    [self setUserDetails:JSONResponse];
    return self;
}


-(void)setUserDetails:(NSString *)JSONString
{

    self.userId = [JSONString valueForKey:@"userId"];
    self.connected = [JSONString valueForKey:@"connected"];
    self.lastSeenAtTime = (NSString *)[JSONString valueForKey:@"lastSeenAtTime"];
    //self.unreadCount = [JSONString valueForKey:@"unreadCount"];

}

-(void)userDetail
{
    NSLog(@"USER ID : %@",self.userId);
    NSLog(@"CONNECTED : %@",self.connected);
    NSLog(@"LAST SEEN : %@",self.lastSeenAtTime);
    //NSLog(@"UNREAD COUNT : %@",self.unreadCount);
}

-(id)initWithDictonary:(NSDictionary *)messageDictonary{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson;
{

    self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
    self.connected = [self getStringFromJsonValue:messageJson[@"connected"]];
    self.lastSeenAtTime = [self getStringFromJsonValue:messageJson[@"lastSeenAtTime"]];
    self.displayName = [self getStringFromJsonValue:messageJson[@"displayName"]];
   // self.self.unreadCount = [self getStringFromJsonValue:messageJson[@"self.unreadCount"]];
  
}


@end
