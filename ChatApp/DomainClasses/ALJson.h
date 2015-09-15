//
//  ALJson.h
//  LearnApp
//
//  Created by devashish on 24/07/2015.
//  Copyright (c) 2015 devashish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALJson : NSObject

-(instancetype)initWithJSONString:(NSString *)JSONString;

-(NSDictionary *)dictionary;

@end
