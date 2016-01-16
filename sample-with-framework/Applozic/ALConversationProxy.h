//
//  ALConversationProxy.h
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface ALConversationProxy : ALJson

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *topicDetail;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic) BOOL created;
@property (nonatomic, strong) NSString *senderUserName;
@property (nonatomic, strong) NSString *applicationKey;
@property (nonatomic, strong) NSNumber *groupId;

@property (nonatomic, strong) NSMutableArray *supportIds;

-(void)parseMessage:(id) messageJson;
-(id)initWithDictonary:(NSDictionary *)messageDictonary;

@end
