//
//  ALMessageList.h
//  ChatApp
//
//  Created by Devashish on 22/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"


@interface ALMessageList : ALJson


@property(nonatomic) NSMutableArray * messageList;

@property(nonatomic) NSMutableArray * connectedUserList;


@end
