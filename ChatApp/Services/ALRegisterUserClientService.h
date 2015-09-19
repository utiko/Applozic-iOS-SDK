//
//  ALRegisterUserClientService.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALRegistrationResponse.h"
#import "ALUser.h"
#import "ALConstant.h"


@interface ALRegisterUserClientService : NSObject

-(void) createAccountWithCallback:(ALUser *)user withCompletion:(void(^)(NSString * message, NSError * error)) completion;

-(ALRegistrationResponse *)createAccount:(ALUser *)user;

@end
