//
//  ALUserClientService.m
//  Applozic
//
//  Created by Devashish on 21/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALUserClientService.h"
#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALUserDefaultsHandler.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"

@implementation ALUserClientService

+(void)userLastSeenDetail:(NSNumber *)lastSeenAt withCompletion:(void(^)(ALLastSeenSyncFeed *))completionMark
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/user/status",KBASE_URL];
    if(!lastSeenAt){
        lastSeenAt = [ALUserDefaultsHandler getLastSyncTime];
        NSLog(@"lastSeenAt is coming as null seeting default vlaue to %@", lastSeenAt);
    }
    NSString * theParamString = [NSString stringWithFormat:@"lastSeenAt=%@",lastSeenAt.stringValue];
    NSLog(@"calling last seen at api for userIds: %@", theParamString);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"USER_LAST_SEEN_NEW" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError)
        {
            NSLog(@"ERROR IN LAST SEEN %@", theError);
        }
        else
        {
            NSLog(@"SEVER RESPONSE FROM JSON : %@", (NSString *)theJson);
            NSNumber * generatedAt =  [theJson  valueForKey:@"generatedAt"];
            [ALUserDefaultsHandler setLastSeenSyncTime:generatedAt];
            ALLastSeenSyncFeed  * responseFeed =  [[ALLastSeenSyncFeed alloc] initWithJSONString:(NSString*)theJson];
            
            completionMark(responseFeed);
        }
        
        
    }];
    
}
@end
