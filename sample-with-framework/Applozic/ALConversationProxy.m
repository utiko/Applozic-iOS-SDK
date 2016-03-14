//
//  ALConversationProxy.m
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationProxy.h"
#import "DB_ConversationProxy.h"

@implementation ALConversationProxy

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}


-(ALConversationProxy *) convertAlConversationProxy:(DB_ConversationProxy *) dbConversation{
    
    ALConversationProxy * alConversationProxy = [[ALConversationProxy alloc] init];
    
    alConversationProxy.created =dbConversation.created.boolValue;
    alConversationProxy.closed = dbConversation.closed.boolValue;
    alConversationProxy.Id = dbConversation.iD;
    alConversationProxy.topicId = dbConversation.topicId;
    alConversationProxy.topicDetailJson =dbConversation.topicDetailJson;
    alConversationProxy.groupId = dbConversation.groupId;
    alConversationProxy.userId =  dbConversation.userId;
    NSLog(@" parseMessage  called for conversation proxy topicDetailJson : %@",self.topicDetailJson);
    return alConversationProxy;
}



-(void)parseMessage:(id) messageJson
{
    self.created = [self getBoolFromJsonValue:messageJson[@"created"]];
    self.Id = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.topicId = [self getStringFromJsonValue:messageJson[@"topicId"]];
    self.topicDetailJson =[self getStringFromJsonValue:messageJson[@"topicDetail"]];

}

-(ALTopicDetail*)getTopicDetail {
    return (self.topicDetailJson)?[[ALTopicDetail alloc] initWithJSONString:self.topicDetailJson]: nil;
}

-(NSMutableDictionary *)getDictionaryForCreate:(ALConversationProxy *)alConversationProxy{
    
    NSMutableDictionary * requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setValue:alConversationProxy.topicId forKey:@"topicId"];
    [requestDict setValue:alConversationProxy.userId forKey:@"userId"];
    [requestDict setValue:alConversationProxy.topicDetailJson forKey:@"topicDetail"];
    return requestDict;
 
}

@end
