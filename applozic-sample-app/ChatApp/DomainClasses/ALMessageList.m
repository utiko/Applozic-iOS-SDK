//
//  ALMessageList.m
//  ChatApp
//
//  Created by Devashish on 22/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMessageList.h"
#import "ALMessage.h"

@implementation ALMessageList


- (id)initWithJSONString:(NSString *)syncMessageResponse {
    
    [self parseMessagseArray:syncMessageResponse];
    return self;
}

-(void)parseMessagseArray:(id) messagejson
{
    NSMutableArray * theMessagesArray = [NSMutableArray new];
    
    NSDictionary * theMessageDict = [messagejson valueForKey:@"message"];

    for (NSDictionary * theDictionary in theMessageDict) {
          ALMessage *message = [[ALMessage alloc] initWithDictonary:theDictionary ];
        [theMessagesArray addObject:message];
    }
    self.messageList = theMessagesArray;
  }


@end
