//
//  ALRegisterUserClientService.m
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define INVALID_APPLICATIONID = @"INVALID_APPLICATIONID"


#import "ALRegisterUserClientService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALParsingHandler.h"
#import "ALUtilityClass.h"
#import "ALRegistrationResponse.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageDBService.h"

@implementation ALRegisterUserClientService


-(void) createAccountWithCallback:(ALUser *)user withCompletion:(void(^)(ALRegistrationResponse * response , NSError * error)) completion {
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/registration/v1/register",KBASE_URL];
    
    //Todo: fetch application key from configurable properties.
    [user setApplicationId: @"applozic-sample-app"];
    [user setDeviceType:1];
    [user setPrefContactAPI:2];
    [user setEmailVerified:false];
    [user setDeviceType:4];
    [user setAppVersionCode: @"71"];
    
    
    //NSString * theParamString = [ALUtilityClass generateJsonStringFromDictionary:userInfo];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:user.dictionary options:0 error:&error];
    NSString *theParamString = [[NSString alloc]initWithData:postdata encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CREATE ACCOUNT" WithCompletionHandler:^(id theJson, NSError *theError) {
        NSLog(@"server response received %@", theJson);
        
        NSString *statusStr = (NSString *)theJson;
        
        /*NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        
        if ([statusStr rangeOfString: @"<html"].location != NSNotFound) {
            //[errorDetail setValue:@"Failed to process from server" forKey:NSLocalizedDescriptionKey];
            theError = [NSError errorWithDomain:@"server" code:200 userInfo:errorDetail];
        }
        
        if ([statusStr rangeOfString: @"INVALID_APPLICATIONID"].location != NSNotFound) {
            //[errorDetail setValue:@"Invalid Application Id" forKey:NSLocalizedDescriptionKey];
            theError = [NSError errorWithDomain:@"server" code:200 userInfo:errorDetail];
        }*/
        
        if (theError) {
            
            completion(nil,theError);
            
            return ;
        }
        
        ALRegistrationResponse *response = [[ALRegistrationResponse alloc] initWithJSONString:statusStr];
        
        //mobiComUserPreference.setCountryCode(user.getCountryCode());
        [ALUserDefaultsHandler setUserId:user.userId];
        //mobiComUserPreference.setContactNumber(user.getContactNumber());
    
        [ALUserDefaultsHandler setEmailVerified: user.emailVerified];
        [ALUserDefaultsHandler setDisplayName: user.displayName];
        [ALUserDefaultsHandler setEmailId:user.emailId];
        [ALUserDefaultsHandler setDeviceKeyString:response.deviceKeyString];
        [ALUserDefaultsHandler setUserKeyString:response.suUserKeyString];
        [ALUserDefaultsHandler setLastSyncTime:response.lastSyncTime];
        completion(response,nil);
        
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

-(void) logout
{
    [ALUserDefaultsHandler clearAll];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    [messageDBService deleteAllObjectsInCoreData];
}

@end
