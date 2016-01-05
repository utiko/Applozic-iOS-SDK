//
//  ALChannel.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannel.h"

@interface ALChannel ()

@end

@implementation ALChannel

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson
{
    self.key = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.name = [self getStringFromJsonValue:messageJson[@"name"]];
    self.adminKey = [self getStringFromJsonValue:messageJson[@"adminName"]];
    self.unreadCount = [self getNSNumberFromJsonValue:messageJson[@"unreadCount"]];
//    self.userCount = [self getNSNumberFromJsonValue:messageJson[@""]];
    self.membersName = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersName"]];
}

@end
