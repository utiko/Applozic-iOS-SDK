//
//  ALContact.m
//  ChatApp
//
//  Created by shaik riyaz on 15/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALContact.h"

@implementation ALContact



-(instancetype)initWithDict:(NSDictionary * ) dictionary {
    self = [super init];
    [self populateDataFromDictonary:dictionary];
    return self;
    
}

-(void)populateDataFromDictonary:(NSDictionary *)dict{
    
    self.userId = [dict objectForKey:@"userId"] ;
    self.fullName = [dict objectForKey:@"fullName"];
    self.contactNumber = [dict objectForKey:@"contactNumber"];
    self.displayName = [dict objectForKey:@"displayName"];
    self.contactImageUrl = [dict objectForKey:@"contactImageUrl"];
    self.email = [dict objectForKey:@"email"];
    self.localImageResourceName = [dict objectForKey:@"localImageResourceName"];
    self.applicationId = [dict objectForKey:@"applicationId"];
}

@end
