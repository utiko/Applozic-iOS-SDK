//
//  ALChannelFeed.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALChannelFeed : NSObject

@property NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *adminName;
@property (nonatomic, strong) NSMutableArray *members;

@end
