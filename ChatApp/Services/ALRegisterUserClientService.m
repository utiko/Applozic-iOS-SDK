//
//  ALRegisterUserClientService.m
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//


#import "ALRegisterUserClientService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALParsingHandler.h"
#import "ALUtilityClass.h"

@implementation ALRegisterUserClientService


-(void) createAccountWithCallback:(ALUser *)user withCompletion:(void(^)(NSString * message, NSError * error)) completion {
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/registration/v1/register",KBASE_URL];
    
    //Todo: fetch application key from configurable properties.
    [user setApplicationId: @"applozic-sample-app"];
    [user setDeviceType:1];
    [user setPrefContactAPI:2];
    [user setEmailVerified:TRUE];
    
    
    //NSString * theParamString = [ALUtilityClass generateJsonStringFromDictionary:userInfo];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:user.dictionary options:0 error:&error];
    NSString *theParamString = [[NSString alloc]initWithData:postdata encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CREATE ACCOUNT" WithCompletionHandler:^(id theJson, NSError *theError) {
        NSLog(@"server response received");
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        
        NSString *statusStr = (NSString *)theJson;
        
        
        completion(statusStr,nil);
        
    }];
    
}


-(ALRegistrationResponse *)createAccount:(ALUser *) user {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://mobi-com-alpha.appspot.com/rest/ws/registration/v1/register"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"applozic-sample-app" forHTTPHeaderField:@"Application-Key"];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:user.dictionary options:0 error:&error];
    
    NSLog(@"posting data: %@", [[NSString alloc]initWithData:postdata encoding:NSUTF8StringEncoding]);
    
    [request setHTTPBody:postdata];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
   /* [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,        NSError *error)
     {
         NSLog(@"Response is:%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
     }];*/
    
    NSString *strData = [[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Registration response from server:%@", strData);
    
    ALRegistrationResponse *registrationResponse = [[ALRegistrationResponse alloc] initWithJSONString:strData];
    
    NSLog(@"Converted to registrationresponse object: %@", registrationResponse.message);
    
    return registrationResponse;
}

@end
