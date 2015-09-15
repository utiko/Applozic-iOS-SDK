//
//  ALRequestHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALRequestHandler.h"
#import "ALUtilityClass.h"

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
    
    [theRequest setURL:theUrl];
    
    [theRequest setTimeoutInterval:600];
    
    [theRequest setHTTPMethod:@"GET"];
    
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [theRequest addValue:@"applozic-sample-app" forHTTPHeaderField:@"Application-Key"];
    
    [theRequest addValue:@"true" forHTTPHeaderField:@"UserId-Enabled"];
    
    [theRequest setValue:@"Basic Y3VzdG9tZXItMTphZ3B6Zm1Gd2NHeHZlbWxqY2lZTEVnWlRkVlZ6WlhJWWdJQ0FnS19obVFvTUN4SUdSR1YyYVdObEdJQ0FnSUNBZ0lBS0RB" forHTTPHeaderField:@"Authorization"];
    
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
    
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [theRequest addValue:@"applozic-sample-app" forHTTPHeaderField:@"Application-Key"];
    
    [theRequest addValue:@"true" forHTTPHeaderField:@"UserId-Enabled"];
    
    [theRequest setValue:@"Basic Y3VzdG9tZXItMTphZ3B6Zm1Gd2NHeHZlbWxqY2lZTEVnWlRkVlZ6WlhJWWdJQ0FnS19obVFvTUN4SUdSR1YyYVdObEdJQ0FnSUNBZ0lBS0RB" forHTTPHeaderField:@"Authorization"];
    
    return theRequest;
    
}


@end
