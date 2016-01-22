//
//  ALAPIResponse.m
//  Applozic
//
//  Created by Devashish on 21/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALAPIResponse.h"

@implementation ALAPIResponse


-(id)initWithJSONString:(NSString *)JSONString
{
    [self parseMessage:JSONString];
    return self;
}

-(void)parseMessage:(id) json;
{
    self.status = [self getStringFromJsonValue:json[@"status"]];
    self.generatedAt = [self getNSNumberFromJsonValue:json[@"generatedAt"]];
    //    self.response = [json valueForKey:json[@"response"]];
    
    NSLog(@"self.generatedAt : %@",self.generatedAt);
    NSLog(@"self.status : %@",self.status);
    
}

@end
