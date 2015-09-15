//
//  ALParsingHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALParsingHandler.h"
#import "ALFileMetaInfo.h"

@implementation ALParsingHandler

+(NSMutableArray *) parseMessagseArray:(id) messagejson
{
    NSMutableArray * theMessagesArray = [NSMutableArray new];
    
    NSDictionary * theMessageDict = [messagejson valueForKey:@"message"];

    if ([self validateJsonClass:theMessageDict] == NO) {
        
        return theMessagesArray;
    }
    
    for (NSDictionary * theDictionary in theMessageDict) {
        
        [theMessagesArray addObject:[self parseMessage:theDictionary]];
    }
    
    return theMessagesArray;
}

+(ALMessage *) parseMessage:(id) messageJson;
{
    ALMessage * message = [ALMessage new];
    
    // class checking
    
    if ([self validateJsonClass:messageJson] == NO) {
        
        return message;
    }
    
    // key String
    
    message.keyString = [self getStringFromJsonValue:messageJson[@"keyString"]];
    

    // device keyString
    
    message.deviceKeyString = [self getStringFromJsonValue:messageJson[@"deviceKeyString"]];

    
    // su user keyString
    
    message.suUserKeyString = [self getStringFromJsonValue:messageJson[@"suUserKeyString"]];

    
    // to
    
    message.to = [self getStringFromJsonValue:messageJson[@"to"]];

    
    // message
    
    message.message = [self getStringFromJsonValue:messageJson[@"message"]];

    
    // sent
    
    message.sent = [self getBoolFromJsonValue:messageJson[@"sent"]];


    // sendToDevice
    
    message.sendToDevice = [self getBoolFromJsonValue:messageJson[@"sendToDevice"]];

  
    // shared
    
    message.shared = [self getBoolFromJsonValue:messageJson[@"shared"]];

    
    // createdAtTime
    
    message.createdAtTime = [self getStringFromJsonValue:messageJson[@"createdAtTime"]];
    
  
    // type
    
    message.type = [self getStringFromJsonValue:messageJson[@"type"]];
    
    
    // source
    
    message.source = [self getStringFromJsonValue:messageJson[@"source"]];

  
    
    // contactIds
    
    message.contactIds = [self getStringFromJsonValue:messageJson[@"contactIds"]];

    
    // storeOnDevice
    
    message.storeOnDevice = [self getBoolFromJsonValue:messageJson[@"storeOnDevice"]];

    
    // read
    
    message.read = [self getBoolFromJsonValue:messageJson[@"read"]];

    
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
            
                message.fileMetas = theFileMetaInfo;
            }
        }
    }
    
    return message;
}

+(BOOL) validateJsonClass:(NSDictionary *) jsonClass
{
    
    if ([NSStringFromClass([jsonClass class]) isEqual:@"NSNUll"] || jsonClass == nil) {
        
        return NO;
    }
    
    return YES;
    
}

+(BOOL) validateJsonArrayClass:(NSArray *) jsonClass
{
    
    if ([NSStringFromClass([jsonClass class]) isEqual:@"NSNUll"] || jsonClass == nil) {
        
        return NO;
    }
    
    return YES;
    
}

+(NSString *) getStringFromJsonValue:(id) jsonValue
{
    if (jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [NSString stringWithFormat:@"%@",jsonValue];
    }
    
    return nil;
}


+(BOOL ) getBoolFromJsonValue:(id) jsonValue
{
    if (jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [jsonValue boolValue];
    }
    
    return NO;
}

@end
