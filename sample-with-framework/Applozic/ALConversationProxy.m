//
//  ALConversationProxy.m
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationProxy.h"

@implementation ALConversationProxy

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson
{
    self.created = [self getBoolFromJsonValue:messageJson[@"created"]];
    self.ID = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.topicId = [self getStringFromJsonValue:messageJson[@"topicId"]];
    self.groupId = [self getNSNumberFromJsonValue:messageJson[@"groupId"]];
}

@end
