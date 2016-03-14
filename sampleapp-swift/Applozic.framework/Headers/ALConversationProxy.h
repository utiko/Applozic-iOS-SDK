//
//  ALConversationProxy.h
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"
#import "ALTopicDetail.h"
#import "DB_ConversationProxy.h"


@interface ALConversationProxy : ALJson

@property (nonatomic, strong) NSNumber *Id;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *topicDetailJson;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSArray  *supportIds;

@property (nonatomic) BOOL created;
@property(nonatomic ) BOOL closed;


-(void)parseMessage:(id) messageJson;
-(id)initWithDictonary:(NSDictionary *)messageDictonary;
-(ALTopicDetail*)getTopicDetail;
-(NSMutableDictionary *)getDictionaryForCreate:(ALConversationProxy *)alConversationProxy;

@end
