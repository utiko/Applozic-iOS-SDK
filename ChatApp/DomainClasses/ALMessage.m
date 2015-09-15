//
//  ALMessage.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessage.h"
#import "ALUtilityClass.h"

@implementation ALMessage

-(NSString *)getCreatedAtTime:(BOOL)today {
    
    NSString *formattedStr = today?@"hh:mm":@"dd MMM hh:mm";
    
    NSString *formattedDateStr = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue] toFormat:formattedStr];
    
    return formattedDateStr;
}

@end
