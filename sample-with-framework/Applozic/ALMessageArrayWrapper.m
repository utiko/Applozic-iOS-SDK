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
    
    ALMessage *msgLast = [self.messageArray lastObject];
    if([msgLast isEqual:almessage])
    {
        [self.messageArray removeObject:almessage];
        ALMessage *msg = [self.messageArray lastObject];
        if([msg.type isEqualToString:@"100"])
        {
            [self.messageArray removeObject:msg];
        }
    }
    else
    {
        int x = (int)[self.messageArray indexOfObject:almessage];
        ALMessage *prev = [self.messageArray objectAtIndex:x - 1];
        ALMessage *next = [self.messageArray objectAtIndex:x + 1];
        if([prev.type isEqualToString:@"100"] && [next.type isEqualToString:@"100"])
        {
            [self.messageArray removeObject:prev];
        }
        [self.messageArray removeObject:almessage];
    }
    
}

-(void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    tempArray = [NSMutableArray arrayWithArray:self.messageArray];
    [tempArray addObjectsFromArray:paramMessageArray];
    
    int countX  =((int)self.messageArray.count==0)?1:((int)self.messageArray.count);
//    NSLog(@"total idex count %d and total temparraycount : %lu", countX , tempArray.count);
    for(int i = (int)(tempArray.count-1); i > countX; i--)
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


-(void)addLatestObjectToArray:(NSMutableArray *)paramMessageArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    tempArray = [NSMutableArray arrayWithArray:self.messageArray];
    [tempArray addObjectsFromArray:paramMessageArray];
    
    int countX  =((int)self.messageArray.count==0)?1:((int)self.messageArray.count);
    NSLog(@"total idex count %d and total temparraycount : %lu", countX , tempArray.count);
    for(int i = countX-1 ; i  < (tempArray.count-1) ; i++)
    {
        ALMessage * msg1 = tempArray[i];
        ALMessage * msg2 = tempArray[i+1];
        
        
        if([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime])
        {
            ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[i]];
            [self.messageArray addObject:dateLabel];
        }
        [self.messageArray addObject:tempArray[i+1] ];

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
    
    if([newerDateString isEqualToString:olderDateString])
    {
        return NO;
    }
    else
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
    
  
}

-(NSString *)msgAtTop:(ALMessage *)almessage
{
    double old = [almessage.createdAtTime doubleValue];
    NSDate *olderDate = [[NSDate alloc] initWithTimeIntervalSince1970:(old/1000)];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *string = [format stringFromDate:olderDate];
    
    NSDate *current = [[NSDate alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *todaydate = [format stringFromDate:current];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSString *yesterdaydate = [format stringFromDate:yesterday];
    NSString *actualDate = @"";
    
    if([string isEqualToString:todaydate])
    {
        actualDate = @"Today";
    }
    else if ([string isEqualToString:yesterdaydate])
    {
        actualDate = @"Yesterday";
    }
    else
    {
        [format setDateFormat:@"EEEE MMM dd,yyyy"];
        actualDate = [format stringFromDate:olderDate];
    }
    
    return actualDate;
    
}

@end
