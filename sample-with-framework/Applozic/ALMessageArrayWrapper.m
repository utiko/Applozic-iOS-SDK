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

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.messageArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSMutableArray *)getUpdatedMessageArray
{
    return self.messageArray;
}

-(void)addALMessageToMessageArray:(ALMessage *)alMessage
{
    if([self getUpdatedMessageArray].count == 0)
    {
        ALMessage *dateLabel = [self getDatePrototype:@"Today" andAlMessageObject:alMessage];
        [self.messageArray addObject:dateLabel];
    }
    else
    {
        ALMessage *msg = [self.messageArray lastObject];
        if([self checkDateOlder:msg.createdAtTime andNewer:alMessage.createdAtTime])
        {
            ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:alMessage];
            [self.messageArray addObject:dateLabel];
        }
    }
    
   [self.messageArray addObject:alMessage];
}

-(void)removeALMessageFromMessageArray:(ALMessage *)almessage
{
    [self.messageArray removeObject:almessage];
}

-(void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    tempArray = [NSMutableArray arrayWithArray:paramMessageArray];
    
    for(int i = (int)(tempArray.count-1); i > 0; i--)
    {
        ALMessage * msg1 = tempArray[i - 1];
        ALMessage * msg2 = tempArray[i];
        
        [self.messageArray insertObject:tempArray[i] atIndex:0];

        if([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime])
        {
            ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[i]];
            [self.messageArray insertObject:dateLabel atIndex:0];
        }
    }
    [tempArray removeAllObjects];
}

-(ALMessage *)getDatePrototype:(NSString *)messageText andAlMessageObject:(ALMessage *)almessage
{
    ALMessage *dateLabel = [[ALMessage alloc] init];
    dateLabel.createdAtTime = almessage.createdAtTime;
    dateLabel.message = messageText;
    dateLabel.type = @"100";
    dateLabel.fileMeta.thumbnailUrl = nil;
    
    return  dateLabel;
}

-(void)removeObjectFromMessageArray:(NSMutableArray *)paramMessageArray
{
    [self.messageArray removeObject:paramMessageArray];
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
