//
//  ALMessageDBService.m
//  ChatApp
//
//  Created by Devashish on 21/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMessageDBService.h"
#import "ALContact.h"
#import "ALDBHandler.h"
#import "DB_Message.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessage.h"
#import "DB_FileMetaInfo.h"
#import "ALMessageService.h"

@implementation ALMessageDBService


//Add message APIS

-(void)addMessageList:(NSMutableArray*) messageList {
   
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    for (ALMessage * theMessage in messageList) {
        
        //Duplicate check before inserting into DB...
        NSManagedObject *message =  [self getMessageByKey:@"keyString" value:theMessage.keyString];
        if(message!=nil){
            //NSLog(@"message with key %@ found",theMessage.keyString );
            continue;
        }
        
        DB_Message * theSmsEntity= [self createSMSEntityForDBInsertionWithMessage:theMessage];
        [theDBHandler.managedObjectContext save:nil];
        theMessage.msgDBObjectId = theSmsEntity.objectID;

    }
    
    [theDBHandler.managedObjectContext save:nil];

}

-(DB_Message*)addMessage:(ALMessage*) message{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_Message* dbMessag = [self createSMSEntityForDBInsertionWithMessage:message];
    [theDBHandler.managedObjectContext save:nil];
    message.msgDBObjectId = dbMessag.objectID;
    return dbMessag;
}

-(NSManagedObject *)getMeesageById:(NSManagedObjectID *)objectID
                             error:(NSError **)error{
    
   ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
   NSManagedObject *obj =  [theDBHandler.managedObjectContext existingObjectWithID:objectID error:error];
   return obj;
}
//update Message APIS
-(void)updateMessageDeliveryReport:(NSString*)keyString{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSManagedObject* message = [self getMessageByKey:@"keyString"  value:keyString];
    [message setValue:[NSNumber numberWithBool:YES] forKey:@"delivered"];
    NSError *error = nil;
    if ( [dbHandler.managedObjectContext save:&error]){
        NSLog(@"message found and maked as deliverd");
    } else {
        NSLog(@"message not found with this key");
    }
    
}


-(void)updateMessageSyncStatus:(NSString*) keyString{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSManagedObject* message = [self getMessageByKey:@"keyString" value:keyString];
    [message setValue:@"1" forKey:@"isSent"];
    NSError *error = nil;
    if ( [dbHandler.managedObjectContext save:&error]){
        NSLog(@"message found and maked as deliverd");
    } else {
        NSLog(@"message not found with this key");
    }
}


//Delete Message APIS

-(void) deleteMessage{
    
}

-(void) deleteMessageByKey:(NSString*) keyString {
    
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSManagedObject* message = [self getMessageByKey:@"keyString" value:keyString];
    [dbHandler.managedObjectContext deleteObject:message];
    NSError *error = nil;
  
    if ( [dbHandler.managedObjectContext save:&error]){
        NSLog(@"message found and maked as deliverd");
    } else {
        NSLog(@"message not found with this key");
    }
}

-(void) deleteAllMessagesByContact: (NSString*) contactId{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
   
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %@",contactId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_Message *message in result) {
        [dbHandler.managedObjectContext deleteObject:message];
    }
    
    NSError *deleteError = nil;
    
   BOOL success = [dbHandler.managedObjectContext save:&deleteError];
    
    if (!success) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
    
}

//Generic APIS
-(BOOL) isMessageTableEmpty{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];
    NSError *error = nil;
    NSUInteger count = [ dbHandler.managedObjectContext countForFetchRequest: fetchRequest error: &error];
    if(error == nil ){
        return !(count >0);
    }else{
         NSLog(@"Error fetching count :%@",error);
    }
    return true;
}

- (void)deleteAllObjectsInCoreData
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSArray *allEntities = dbHandler.managedObjectModel.entities;
    for (NSEntityDescription *entityDescription in allEntities)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        
        fetchRequest.includesPropertyValues = NO;
        fetchRequest.includesSubentities = NO;
        
        NSError *error;
        NSArray *items = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"Error requesting items from Core Data: %@", [error localizedDescription]);
        }
        
        for (NSManagedObject *managedObject in items) {
            [dbHandler.managedObjectContext deleteObject:managedObject];
        }
        
        if (![dbHandler.managedObjectContext save:&error]) {
            NSLog(@"Error deleting %@ - error:%@", entityDescription, [error localizedDescription]);
        }
    }  
}

- (NSManagedObject *)getMessageByKey:(NSString *) key value:(NSString*) value{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",key,value];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (result.count > 0) {
        NSManagedObject* message = [result objectAtIndex:0];
        return message;
    } else {
        NSLog(@"message not found with this key");
        return nil;
    }
}

//------------------------------------------------------------------------------------------------------------------
    #pragma mark - ALMessagesViewController DB Operations.
//------------------------------------------------------------------------------------------------------------------

-(void)getMessages {

    if ( [self isMessageTableEmpty ] ) { // db is not synced
        [self fetchAndRefreshFromServer];
        [self syncConactsDB];
    }
    else // db is synced
    {
        //fetch data from db
        [self fetchConversationsGroupByContactId];
    }
}

-(void)fetchAndRefreshFromServer{
    
    [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray * theArray) {
        
        if (success) {
            // save data into the db
            [self addMessageList:theArray];
            // set yes to userdefaults
            [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
            // add default contacts
            //fetch data from db
            [self fetchConversationsGroupByContactId];
        }
    }];
}

-(void)fetchAndRefreshFromServerForPush{
    
    NSString * lastSyncTime = [ALUserDefaultsHandler getLastSyncTime];
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
    
    [ALMessageService getLatestMessageForUser:deviceKeyString lastSyncTime:lastSyncTime withCompletion:^(NSMutableArray *messageArray, NSError *error) {
       
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        [self addMessageList:messageArray];
        [self fetchConversationsGroupByContactId];
    }];

}
//------------------------------------------------------------------------------------------------------------------
    #pragma mark -  Helper methods
//------------------------------------------------------------------------------------------------------------------

-(void)syncConverstionDBWithCompletion:(void(^)(BOOL success , NSMutableArray * theArray)) completion
{
    //[self.mActivityIndicator startAnimating];
    [ALMessageService getMessagesListGroupByContactswithCompletion:^(NSMutableArray *messageArray, NSError *error) {
      //  [self.mActivityIndicator stopAnimating];
        if (error) {
            NSLog(@"%@",error);
            completion(NO,nil);
            return ;
        }
        NSMutableArray * dataArray = [NSMutableArray arrayWithArray:messageArray];
        completion(YES,dataArray);
    }];
}

-(void)syncConactsDB
{
    //TODO: Update with valid contacts.
    // adding default data
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];

    // contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"111";
    contact1.fullName = @"Gaurav Nigam";
    contact1.contactNumber = @"1234561234";
    contact1.displayName = @"Gaurav";
    contact1.email = @"123@abc.com";
    contact1.contactImageUrl = nil;

    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"222";
    contact2.fullName = @"Navneet Nav";
    contact2.contactNumber = @"987651234";
    contact2.displayName = @"Navneet";
    contact2.email = @"456@abc.com";
    contact2.contactImageUrl = nil;

    // contact 3
    ALContact *contact3 = [[ALContact alloc] init];
    contact3.userId = @"applozic";
    contact3.fullName = @"applozic";
    contact3.contactNumber = @"678906543";
    contact3.displayName = @"Priyesh";
    contact3.email = @"789@abc.com";
    contact3.contactImageUrl = nil;

    [theDBHandler addListOfContacts:@[contact1,contact2,contact3]];
}

-(void)fetchConversationsGroupByContactId
{
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    // get all unique contacts

    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setResultType:NSDictionaryResultType];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [theRequest setPropertiesToFetch:@[@"contactId"]];
    [theRequest setReturnsDistinctResults:YES];

    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    // get latest record
    NSMutableArray *messagesArray = [NSMutableArray new];
    for (NSDictionary * theDictionary in theArray) {
        NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
        [theRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId = %@",theDictionary[@"contactId"]]];
        [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [theRequest setFetchLimit:1];

        NSArray * theArray =  [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
        DB_Message * theSmsEntity = theArray.firstObject;
        ALMessage * theMessage = [ALMessage new];
        theMessage.to = theSmsEntity.to;
        theMessage.message = theSmsEntity.messageText;
        theMessage.contactIds = theSmsEntity.contactId;
        theMessage.type = theSmsEntity.type;
        theMessage.createdAtTime = [NSString stringWithFormat:@"%@",theSmsEntity.createdAt];
        [messagesArray addObject:theMessage];
    }

    if ([self.delegate respondsToSelector:@selector(getMessagesArray:)]) {
        [self.delegate getMessagesArray:messagesArray];
    }
}

-(DB_Message *) createSMSEntityForDBInsertionWithMessage:(ALMessage *) theMessage
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_Message * theSmsEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_Message" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    theSmsEntity.contactId = theMessage.contactIds;
    theSmsEntity.createdAt = [NSNumber numberWithInteger:theMessage.createdAtTime.integerValue];
    theSmsEntity.deviceKeyString = theMessage.deviceKeyString;
    theSmsEntity.isRead = [NSNumber numberWithBool:theMessage.read];
    theSmsEntity.isSent = [NSNumber numberWithBool:theMessage.sent];
    theSmsEntity.isSentToDevice = [NSNumber numberWithBool:theMessage.sendToDevice];
    theSmsEntity.isShared = [NSNumber numberWithBool:theMessage.shared];
    theSmsEntity.isStoredOnDevice = [NSNumber numberWithBool:theMessage.storeOnDevice];
    theSmsEntity.keyString = theMessage.keyString;
    theSmsEntity.messageText = theMessage.message;
    theSmsEntity.suUserKeyString = theMessage.suUserKeyString;
    theSmsEntity.to = theMessage.to;
    theSmsEntity.type = theMessage.type;
    theSmsEntity.delivered = [NSNumber numberWithBool:theMessage.delivered];
    theSmsEntity.sentToServer = [NSNumber numberWithBool:theMessage.sentToServer];
    theSmsEntity.filePath = theMessage.imageFilePath;
    theSmsEntity.inProgress = [ NSNumber numberWithBool:theMessage.inProgress];
    theSmsEntity.isUploadFailed=[ NSNumber numberWithBool:theMessage.isUploadFailed];
    if(theMessage.fileMetas != nil) {
        DB_FileMetaInfo *  fileInfo =  [self createFileMetaInfoEntityForDBInsertionWithMessage:theMessage.fileMetas];
        theSmsEntity.fileMetaInfo = fileInfo;
    }
    return theSmsEntity;
}

-(DB_FileMetaInfo *) createFileMetaInfoEntityForDBInsertionWithMessage:(ALFileMetaInfo *) fileInfo
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_FileMetaInfo * fileMetaInfo = [NSEntityDescription insertNewObjectForEntityForName:@"DB_FileMetaInfo" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    fileMetaInfo.blobKeyString = fileInfo.blobKeyString;
    
    fileMetaInfo.contentType = fileInfo.contentType;
    
    fileMetaInfo.createdAtTime = fileInfo.createdAtTime;
    
    fileMetaInfo.keyString = fileInfo.keyString;
    
    fileMetaInfo.name = fileInfo.name;
    
    fileMetaInfo.size = fileInfo.size;
    
    fileMetaInfo.suUserKeyString = fileInfo.suUserKeyString;
    
    fileMetaInfo.thumbnailUrl = fileInfo.thumbnailUrl;
    
    return fileMetaInfo;
}

-(ALMessage *) createMessageForSMSEntity:(DB_Message *) theEntity
{
    ALMessage * theMessage = [ALMessage new];
    
    theMessage.msgDBObjectId = [theEntity objectID];
    theMessage.keyString = theEntity.keyString;
    theMessage.deviceKeyString = theEntity.deviceKeyString;
    theMessage.suUserKeyString = theEntity.suUserKeyString;
    theMessage.to = theEntity.to;
    theMessage.message = theEntity.messageText;
    theMessage.sent = theEntity.isSent.boolValue;
    theMessage.sendToDevice = theEntity.isSentToDevice.boolValue;
    theMessage.shared = theEntity.isShared.boolValue;
    theMessage.createdAtTime = [NSString stringWithFormat:@"%@",theEntity.createdAt];
    theMessage.type = theEntity.type;
    theMessage.contactIds = theEntity.contactId;
    theMessage.storeOnDevice = theEntity.isStoredOnDevice.boolValue;
    theMessage.inProgress =theEntity.inProgress.boolValue;
    theMessage.read = theEntity.isRead.boolValue;
    theMessage.imageFilePath = theEntity.filePath;
    theMessage.delivered = theEntity.delivered.boolValue;
    theMessage.sentToServer = theEntity.sentToServer.boolValue;
    theMessage.isUploadFailed = theEntity.isUploadFailed.boolValue;
    
    // file meta info
    
    ALFileMetaInfo * theFileMeta = [ALFileMetaInfo new];
    theFileMeta.blobKeyString = theEntity.fileMetaInfo.blobKeyString;
    theFileMeta.contentType = theEntity.fileMetaInfo.contentType;
    theFileMeta.createdAtTime = theEntity.fileMetaInfo.createdAtTime;
    theFileMeta.keyString = theEntity.fileMetaInfo.keyString;
    theFileMeta.name = theEntity.fileMetaInfo.name;
    theFileMeta.size = theEntity.fileMetaInfo.size;
    theFileMeta.suUserKeyString = theEntity.fileMetaInfo.suUserKeyString;
    theFileMeta.thumbnailUrl = theEntity.fileMetaInfo.thumbnailUrl;
    theMessage.fileMetas = theFileMeta;
    return theMessage;
}

-(void) updateFileMetaInfo:(ALMessage *) almessage{
    
    NSError *error=nil;
    DB_Message * db_Message = (DB_Message*)[self getMeesageById:almessage.msgDBObjectId error:&error];
    almessage.fileMetaKeyStrings = @[almessage.fileMetas.keyString];
    
    db_Message.fileMetaInfo.blobKeyString = almessage.fileMetas.blobKeyString;
    db_Message.fileMetaInfo.contentType = almessage.fileMetas.contentType;
    db_Message.fileMetaInfo.createdAtTime = almessage.fileMetas.createdAtTime;
    db_Message.fileMetaInfo.keyString = almessage.fileMetas.keyString;
    db_Message.fileMetaInfo.name = almessage.fileMetas.name;
    db_Message.fileMetaInfo.size = almessage.fileMetas.size;
    db_Message.fileMetaInfo.suUserKeyString = almessage.fileMetas.suUserKeyString;
    [[ALDBHandler sharedInstance].managedObjectContext save:nil];
    
}

@end
