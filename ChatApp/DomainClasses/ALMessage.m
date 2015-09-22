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
    
    self.keyString =  [super getStringFromJsonValue:messageJson[@"keyString"]];
    
    
    // device keyString
    
    self.deviceKeyString = [self getStringFromJsonValue:messageJson[@"deviceKeyString"]];
    
    
    // su user keyString
    
    self.suUserKeyString = [self getStringFromJsonValue:messageJson[@"suUserKeyString"]];
    
    
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
    
    
    // file meta info
    
    NSArray * fileMetas = messageJson[@"fileMetas"];
    
    if ([self validateJsonArrayClass:fileMetas]) {
        
        if (fileMetas.count > 0) {
            
            NSDictionary * fileMetaDict = fileMetas[0];
            
            if ([self validateJsonClass:fileMetaDict]) {
                
                ALFileMetaInfo * theFileMetaInfo = [ALFileMetaInfo new];
                
                theFileMetaInfo.blobKeyString = [self getStringFromJsonValue:fileMetaDict[@"blobKeyString"]];
                
                theFileMetaInfo.contentType = [self getStringFromJsonValue:fileMetaDict[@"contentType"]];
                
                theFileMetaInfo.createdAtTime = [self getStringFromJsonValue:fileMetaDict[@"createdAtTime"]];
                
                theFileMetaInfo.keyString = [self getStringFromJsonValue:fileMetaDict[@"keyString"]];
                
                theFileMetaInfo.name = [self getStringFromJsonValue:fileMetaDict[@"name"]];
                
                theFileMetaInfo.suUserKeyString = [self getStringFromJsonValue:fileMetaDict[@"suUserKeyString"]];
                
                theFileMetaInfo.size = [self getStringFromJsonValue:fileMetaDict[@"size"]];
                
                theFileMetaInfo.thumbnailUrl = [self getStringFromJsonValue:fileMetaDict[@"thumbnailUrl"]];
                
                self.fileMetas = theFileMetaInfo;
            }
        }
    }
    
   
}


-(NSString *)getCreatedAtTime:(BOOL)today {
    
    NSString *formattedStr = today?@"hh:mm":@"dd MMM hh:mm";
    
    NSString *formattedDateStr = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue] toFormat:formattedStr];
    
    return formattedDateStr;
}

@end
