//
//  ALAPIResponse.h
//  Applozic
//
//  Created by Devashish on 21/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface ALAPIResponse : ALJson

@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSNumber * generatedAt;
@property (nonatomic, strong) id response;
@end
