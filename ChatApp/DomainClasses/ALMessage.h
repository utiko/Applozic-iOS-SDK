//
//  ALMessage.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "ALJson.h"
#import "ALFileMetaInfo.h"


@interface ALMessage : ALJson

@property (nonatomic, copy) NSString * keyString;

@property (nonatomic, copy) NSString * deviceKeyString;

@property (nonatomic, copy) NSString * suUserKeyString;

@property (nonatomic, copy) NSString * to;

@property (nonatomic, copy) NSString * message;

@property (nonatomic, assign) BOOL sent;

@property (nonatomic, assign) BOOL sendToDevice;

@property (nonatomic, assign) BOOL shared;

@property (nonatomic, copy) NSString * createdAtTime;

@property (nonatomic, copy) NSString * type;

@property (nonatomic, copy) NSString * source;

@property (nonatomic, copy) NSString * contactIds;

@property (nonatomic, assign) BOOL storeOnDevice;

@property (nonatomic,retain) ALFileMetaInfo * fileMetas;

@property (nonatomic,assign) BOOL read;

@property (nonatomic,retain) NSString * imageFilePath;

@property (nonatomic,assign) BOOL inProgress;

@property (nonatomic, strong)NSArray *fileMetaKeyStrings;

@property (nonatomic, assign) BOOL isUploadFailed;

@property (nonatomic,assign) BOOL delivered;

@property(nonatomic,assign)BOOL sentToServer;

@property(nonatomic,copy) NSManagedObjectID * msgDBObjectId;

-(NSString *)getCreatedAtTime:(BOOL)today;

-(id)initWithDictonary:(NSDictionary*)messageDictonary;

@end
