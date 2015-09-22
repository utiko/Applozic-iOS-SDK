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
    NSDictionary * theMessageDict = [syncMessageResponse valueForKey:@"message"];
    [self parseMessagseArray:theMessageDict];
    return self;
}



-(void)parseMessagseArray:(id) theMessageDict
{
    NSMutableArray * theMessagesArray = [NSMutableArray new];
    
    
    for (NSDictionary * theDictionary in theMessageDict) {
        ALMessage *message = [[ALMessage alloc] initWithDictonary:theMessageDict ];
        [theMessagesArray addObject:message];
    }
    self.messagesList = theMessagesArray;
}



@end
