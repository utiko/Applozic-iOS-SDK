//
//  ALDateCell.m
//  Applozic
//
//  Created by devashish on 16/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALDateCell.h"

@interface ALDateCell ()

@end

@implementation ALDateCell

-(BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer
{
    double old = [older doubleValue];
    double new = [newer doubleValue];
    
    NSDate *olderDate = [[NSDate alloc] initWithTimeIntervalSince1970:(old/1000)];
    NSDate *newerDate = [[NSDate alloc] initWithTimeIntervalSince1970:(new/1000)];
    
    NSDate *current = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *todaydate = [format stringFromDate:current];
    NSString *newerDateString = [format stringFromDate:newerDate];
    NSString *olderDateString = [format stringFromDate:olderDate];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSString *yesterdaydate = [format stringFromDate:yesterday];
    
    NSTimeInterval difference = [newerDate timeIntervalSinceDate:olderDate];
    
    if(difference >= 86400)
    {
        
        if([newerDateString isEqualToString:todaydate])
        {
            self.dateCellText = @"TODAY";
        }
        else if([newerDateString isEqualToString:yesterdaydate])
        {
            self.dateCellText = @"YESTERDAY";
        }
        else
        {
            [format setDateFormat:@"EEEE MMM dd,yyyy"];
            self.dateCellText = [format stringFromDate:newerDate];
        }
        return YES;
    }
    else
    {
        if([olderDateString isEqualToString:yesterdaydate] && [newerDateString isEqualToString:todaydate])
        {
            self.dateCellText = @"TODAY";
            return YES;
        }
        else if(![newerDateString isEqualToString:todaydate] && ![olderDateString isEqualToString:yesterdaydate] && ![newerDateString isEqualToString:olderDateString])
        {
            [format setDateFormat:@"EEEE MMM dd,yyyy"];
            self.dateCellText = [format stringFromDate:newerDate];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
}


@end
