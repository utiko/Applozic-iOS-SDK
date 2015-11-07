//
//  ALRequestHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALRequestHandler.h"
#import "ALUtilityClass.h"
#import "ALUserDefaultsHandler.h"

@implementation ALRequestHandler

+(NSMutableURLRequest *) createGETRequestWithUrlString:(NSString *) urlString paramString:(NSString *) paramString
{
    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] init];
    
    NSURL * theUrl = nil;
    
    if (paramString != nil) {
        
        theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,[paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    else
    {
        theUrl = [NSURL URLWithString:urlString];
    
    }
    NSLog(@"the url,%@", theUrl);
    [theRequest setURL:theUrl];
    
    [theRequest setTimeoutInterval:600];
    
    [theRequest setHTTPMethod:@"GET"];
    
    [ self addGlobalHeader:theRequest ];
    return theRequest;
}

+(NSMutableURLRequest *) createPOSTRequestWithUrlString:(NSString *) urlString paramString:(NSString *) paramString
{
    
    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [theRequest setTimeoutInterval:600];
    
    [theRequest setHTTPMethod:@"POST"];
    
    if (paramString != nil) {
        
        NSData * thePostData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        
        [theRequest setHTTPBody:thePostData];
        
        [theRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[thePostData length]] forHTTPHeaderField:@"Content-Length"];
        
    }
    [ self addGlobalHeader:theRequest ];
       return theRequest;
    
}

+(void) addGlobalHeader: (NSMutableURLRequest*) request{
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:[ALUserDefaultsHandler getApplicationKey] forHTTPHeaderField:@"Application-Key"];
    [request addValue:@"true" forHTTPHeaderField:@"UserId-Enabled"];
    [request addValue:[ALUserDefaultsHandler getDeviceKeyString] forHTTPHeaderField:@"deviceKey"];

    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@",[ALUserDefaultsHandler getUserId] , [ALUserDefaultsHandler getDeviceKeyString]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    //Add header for device key ....
    
    NSLog(@"Basic string...%@",authString);
}
@end
