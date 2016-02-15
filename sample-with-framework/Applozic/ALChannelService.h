//
//  ALChannelService.h
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChannelFeed.h"
#import "ALChannelDBService.h"
#import "ALChannelClientService.h"
#import "ALUserDefaultsHandler.h"

@interface ALChannelService : NSObject

-(void)callForChannelServiceForDBInsertion:(id)theJson;

-(void)getChannelInformation:(NSNumber *)channelKey withCompletion:(void (^)(ALChannel *alChannel3)) completion;

-(NSString *)getChannelName:(NSNumber *)channelKey;

-(NSString *)stringFromChannelUserList:(NSNumber *)key;

-(void)createChannel:(NSString *)channelName andMembersList:(NSMutableArray *)memberArray withCompletion:(void(^)(NSNumber *channelKey))completion;

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey;

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey;

-(void)deleteChannel:(NSNumber *)channelKey;

-(BOOL)checkAdmin:(NSNumber *)channelKey;

@end
