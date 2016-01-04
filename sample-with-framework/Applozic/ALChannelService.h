//
//  ALChannelService.h
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChannelFeed.h"
#import "ALChannelDBService.h"
#import "ALChannelClientService.h"

@interface ALChannelService : NSObject

-(void)callForChannelServiceForDBInsertion:(id)theJson;
-(void)getChannelInformation:(NSNumber *)channelKey;

@end
