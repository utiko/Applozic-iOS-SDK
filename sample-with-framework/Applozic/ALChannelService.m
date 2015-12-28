//
//  ALChannelService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannelService.h"

@interface ALChannelService ()

@end

@implementation ALChannelService

-(id)initWithArray
{
    self = [super init];
    
    if(self)
    {
        self.contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
