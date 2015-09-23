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
        NSManagedObject *message =  [self getMessageByKey:theMessage.keyString];
        if(message!=nil){
            continue;
        }
        
        
        NSLog(@" adding messages..%@",theMessage.message );
        DB_Message * theSmsEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_Message" inManagedObjectContext:theDBHandler.managedObjectContext];
        theSmsEntity.isSent = [NSNumber numberWithBool:theMessage.sent];
        theSmsEntity.isSentToDevice = [NSNumber numberWithBool:theMessage.sendToDevice];
        theSmsEntity.isStoredOnDevice = [NSNumber numberWithBool:NO];
        theSmsEntity.isShared = [NSNumber numberWithBool:theMessage.shared];
        theSmsEntity.isRead = [NSNumber numberWithBool:theMessage.read];
        theSmsEntity.keyString = theMessage.keyString;
        theSmsEntity.deviceKeyString = theMessage.deviceKeyString;
        theSmsEntity.suUserKeyString = theMessage.suUserKeyString;
        theSmsEntity.to = theMessage.to;
        theSmsEntity.messageText = theMessage.message;
        theSmsEntity.createdAt = [NSNumber numberWithInteger:theMessage.createdAtTime.integerValue];
        theSmsEntity.type = theMessage.type;
        theSmsEntity.contactId = theMessage.contactIds;
        theSmsEntity.filePath = theMessage.imageFilePath;
        
        if (theMessage.fileMetas != nil) {
            DB_FileMetaInfo * theMetaInfoEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_FileMetaInfo" inManagedObjectContext:theDBHandler.managedObjectContext];
            theMetaInfoEntity.blobKeyString = theMessage.fileMetas.blobKeyString;
            theMetaInfoEntity.contentType = theMessage.fileMetas.contentType;
            theMetaInfoEntity.createdAtTime = theMessage.fileMetas.createdAtTime;
            theMetaInfoEntity.keyString = theMessage.fileMetas.keyString;
            theMetaInfoEntity.name = theMessage.fileMetas.name;
            theMetaInfoEntity.size = theMessage.fileMetas.size;
            theMetaInfoEntity.suUserKeyString = theMessage.fileMetas.suUserKeyString;
            theMetaInfoEntity.thumbnailUrl = theMessage.fileMetas.thumbnailUrl;
            theSmsEntity.fileMetaInfo = theMetaInfoEntity;
        }
    }
    
    [theDBHandler.managedObjectContext save:nil];

}

-(void)addMessage:(ALMessage*) message{
    
}

//update Message APIS
-(void)updateMessageDeliveryReport:(NSString*)keyString{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSManagedObject* message = [self getMessageByKey:keyString];
    [message setValue:@"1" forKey:@"delivered"];
    NSError *error = nil;
    if ( [dbHandler.managedObjectContext save:&error]){
        NSLog(@"message found and maked as deliverd");
    } else {
        NSLog(@"message not found with this key");
    }
    
}


-(void)updateMessageSyncStatus:(NSString*) keyString{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSManagedObject* message = [self getMessageByKey:keyString];
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
    
    NSManagedObject* message = [self getMessageByKey:keyString];
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

- (NSManagedObject *)getMessageByKey:(NSString *) keyString{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyString = %@",keyString];
    
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

        [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray * theArray) {

            if (success) {
                // save data into the db
                [self addMessageList:theArray];
                // set yes to userdefaults
                [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
                // add default contacts
                [self syncConactsDB];
                //fetch data from db
                [self fetchConversationsGroupByContactId];
            }
        }];
    }
    else // db is synced
    {
        //fetch data from db
        [self fetchConversationsGroupByContactId];
    }
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

@end
