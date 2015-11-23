//
//  ALMessage.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessage.h"
#import "ALUtilityClass.h"

@implementation ALMessage


-(id)initWithDictonary:(NSDictionary*)messageDictonary{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson;
{
    
    
    // key String
    
    self.key =  [super getStringFromJsonValue:messageJson[@"key"]];
    
    self.pairedMessageKeyString = [super getStringFromJsonValue:messageJson[@"pairedMessageKey"]];
    
    
    // device keyString
    
    self.deviceKey = [self getStringFromJsonValue:messageJson[@"deviceKey"]];
    
    
    // su user keyString
    
    self.userKey = [self getStringFromJsonValue:messageJson[@"suUserKeyString"]];
    
    
    // to
    
    self.to = [self getStringFromJsonValue:messageJson[@"to"]];
    
    
    // message
    
    self.message = [self getStringFromJsonValue:messageJson[@"message"]];
    
    
    // sent
    
    self.sent = [self getBoolFromJsonValue:messageJson[@"sent"]];
    
    
    // sendToDevice
    
    self.sendToDevice = [self getBoolFromJsonValue:messageJson[@"sendToDevice"]];
    
    
    // shared
    
    self.shared = [self getBoolFromJsonValue:messageJson[@"shared"]];
    
    
    // createdAtTime
    
    self.createdAtTime = [self getStringFromJsonValue:messageJson[@"createdAtTime"]];
    
    
    // type
    
    self.type = [self getStringFromJsonValue:messageJson[@"type"]];
    
    
    // source
    
    self.source = [self getStringFromJsonValue:messageJson[@"source"]];
    
    
    
    // contactIds
    
    self.contactIds = [self getStringFromJsonValue:messageJson[@"contactIds"]];
    
    
    // storeOnDevice
    
    self.storeOnDevice = [self getBoolFromJsonValue:messageJson[@"storeOnDevice"]];
    
    
    // read
    
    self.read = [self getBoolFromJsonValue:messageJson[@"read"]];
    
    //develired
    self.delivered = [self getBoolFromJsonValue:messageJson[@"delivered"]];
    // file meta info
    
     NSDictionary * fileMetaDict = messageJson[@"fileMeta"];

            if ([self validateJsonClass:fileMetaDict]) {
                
                ALFileMetaInfo * theFileMetaInfo = [ALFileMetaInfo new];
                
                theFileMetaInfo.blobKey = [self getStringFromJsonValue:fileMetaDict[@"blobKey"]];
                theFileMetaInfo.contentType = [self getStringFromJsonValue:fileMetaDict[@"contentType"]];
                theFileMetaInfo.createdAtTime = [self getStringFromJsonValue:fileMetaDict[@"createdAtTime"]];
                theFileMetaInfo.key = [self getStringFromJsonValue:fileMetaDict[@"key"]];
                theFileMetaInfo.name = [self getStringFromJsonValue:fileMetaDict[@"name"]];
                theFileMetaInfo.userKey = [self getStringFromJsonValue:fileMetaDict[@"userKey"]];
                theFileMetaInfo.size = [self getStringFromJsonValue:fileMetaDict[@"size"]];
                theFileMetaInfo.thumbnailUrl = [self getStringFromJsonValue:fileMetaDict[@"thumbnailUrl"]];
                theFileMetaInfo.url = [self getStringFromJsonValue:fileMetaDict[@"url"]];

                self.fileMeta = theFileMetaInfo;
            }
}


-(NSString *)getCreatedAtTime:(BOOL)today {
    
    NSString *formattedStr = today?@"hh:mm":@"dd MMM hh:mm";

    NSString *formattedDateStr;
   
    NSDate *currentTime = [[NSDate alloc] init];

    float msgTime = [self.createdAtTime floatValue];

    NSDate *msgDate = [[NSDate alloc] init];
    msgDate = [NSDate dateWithTimeIntervalSince1970:msgTime/1000];
    NSTimeInterval difference = [currentTime timeIntervalSinceDate:msgDate];
    
    float minutes;
    if(difference <= 3600)
    {
        if(difference <= 60)
        {
            formattedDateStr = @"Just Now";
        }
        else
        {
            minutes = difference/60;
            formattedDateStr = [NSString stringWithFormat:@"%.0f", minutes];
            formattedDateStr = [formattedDateStr stringByAppendingString:@" min"];
        }
    }
    else if(difference <= 7200)
    {
        minutes = (difference - 3600)/60;
        formattedDateStr = [NSString stringWithFormat:@"%.0f", minutes];
        NSString *hour = @"1hr";
        formattedDateStr = [hour stringByAppendingString:formattedDateStr];
        formattedDateStr = [formattedDateStr stringByAppendingString:@"min"];
    }
    else
    {
       formattedDateStr = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue] toFormat:formattedStr];
    }
    
    return formattedDateStr;
}

-(BOOL)isDownloadRequire{
    
    //TODO:check for SD card
    if ( self.fileMeta && !self.imageFilePath){
        return YES;
    }
    return NO;
}

-(BOOL)isUploadRequire{
    //TODO:check for SD card
    if ( (self.imageFilePath && !self.fileMeta && [ self.type  isEqualToString:@"5"]) || self.isUploadFailed==YES){
        return YES;
    }
    return NO;
}

@end
