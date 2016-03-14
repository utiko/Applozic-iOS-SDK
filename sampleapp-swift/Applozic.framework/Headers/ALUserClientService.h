//
//  ALUserClientService.h
//  Applozic
//
//  Created by Devashish on 21/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALLastSeenSyncFeed.h"
#import "ALContact.h"

@interface ALUserClientService : NSObject

+(void)userLastSeenDetail:(NSNumber *)lastSeenAt withCompletion:(void(^)(ALLastSeenSyncFeed *))completionMark;

-(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark;

-(void)updateUserDisplayName:(ALContact *)alContact withCompletion:(void(^)(id theJson, NSError *theError))completion;

-(void)markConversationAsReadforContact:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)userBlockServerCall:(NSString *)userId withCompletion:(void (^)(NSString *json, NSError *error))completion;

+(void)userBlockSyncServerCall:(NSNumber *)lastSyncTime withCompletion:(void (^)(NSString *json, NSError *error))completion;

@end
