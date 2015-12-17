//
//  ALMessageArrayWrapper.h
//  Applozic
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"

@interface ALMessageArrayWrapper : NSObject

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, strong) NSMutableArray *tempArray;

@property (strong, nonatomic) NSString *dateCellText;

-(BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer;

-(NSMutableArray *)getUpdatedMessageArray;

-(void)addObjectToMessageArray:(NSMutableArray *)messageArray;

-(void)removeObjectFromMessageArray:(NSMutableArray *)messageArray;

@end
