//
//  ALMessageArrayWrapper.m
//  Applozic
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALMessageArrayWrapper.h"

@interface ALMessageArrayWrapper ()

@end

@implementation ALMessageArrayWrapper


-(NSMutableArray *)getUpdatedMessageArray
{
    return self.messageArray;
}

-(void)addObjectToMessageArray:(NSMutableArray *)messageArray
{
    self.tempArray = [[NSMutableArray alloc] init];
    self.messageArray = [[NSMutableArray alloc] init];
    
    self.tempArray = [NSMutableArray arrayWithArray:messageArray];
    
    for(int i = (int)(self.tempArray.count-1); i > 0; i--)
    {
        ALMessage * msg1 = self.tempArray[i - 1];
        ALMessage * msg2 = self.tempArray[i];
        
        [self.messageArray insertObject:self.tempArray[i] atIndex:0];
        
        
        if([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime])
        {
            ALMessage *dateLabel = [[ALMessage alloc] init];
            dateLabel.message = self.dateCellText;
            dateLabel.createdAtTime = [self.tempArray[i] createdAtTime];
            dateLabel.type = @"100";
            dateLabel.fileMeta.thumbnailUrl = nil;
            
            [self.messageArray insertObject:dateLabel atIndex:0];
        }
    }
    
}

-(void)removeObjectFromMessageArray:(NSMutableArray *)messageArray
{
    
}

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
            self.dateCellText = @"Today";
        }
        else if([newerDateString isEqualToString:yesterdaydate])
        {
            self.dateCellText = @"Yesterday";
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
            self.dateCellText = @"Today";
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
