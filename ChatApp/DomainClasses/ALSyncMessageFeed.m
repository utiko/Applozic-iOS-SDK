//
//  ALSyncMessageFeed.m
//  ChatApp
//
//  Created by Devashish on 20/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALSyncMessageFeed.h"

#import "ALMessage.h"
#import "ALParsingHandler.h"


@implementation ALSyncMessageFeed


- (id)initWithJSONString:(NSString *)syncMessageResponse {
    
    self.lastSyncTime = [syncMessageResponse valueForKey:@"lastSyncTime"];
    self.isRegisterdIdInvalid = [syncMessageResponse valueForKey:@"regIdInvalid"];
    NSDictionary *theMessageDict = [syncMessageResponse valueForKey:@"messages"];
    self.messagesList = [self getMessageList:theMessageDict];
    
    return self;
}


-(NSMutableArray *)getMessageList:(NSDictionary*)dict {
    
    NSMutableArray * theMessagesArray = [NSMutableArray new];
    
    if ([ALParsingHandler validateJsonClass:dict] == NO) {
        
        return theMessagesArray;
    }
    
    for (NSDictionary * theDictionary in dict) {
        
        [theMessagesArray addObject:[ ALParsingHandler parseMessage:theDictionary]];
    }
    return theMessagesArray;
}




@end
