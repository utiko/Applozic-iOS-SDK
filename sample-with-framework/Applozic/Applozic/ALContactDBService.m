//
//  ALContactDBService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALConstant.h"

@implementation ALContactDBService

#pragma mark - Delete Contacts API -


- (BOOL)purgeListOfContacts:(NSArray *)contacts {
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self purgeContact:contact];
        
        if (!result) {
            
            NSLog(@"Failure to delete the contacts");
            break;
        }
    }
    
    return result;
}

- (BOOL)purgeContact:(ALContact *)contact {
    
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];


    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        [dbHandler.managedObjectContext deleteObject:userContact];
    }
    
    NSError *deleteError = nil;
    
    success = [dbHandler.managedObjectContext save:&deleteError];
    
    if (!success) {
        
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
    
    return success;
}

- (BOOL)purgeAllContact {
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        [dbHandler.managedObjectContext deleteObject:userContact];
    }
    
    NSError *deleteError = nil;
    
    success = [dbHandler.managedObjectContext save:&deleteError];
    
    if (!success) {
        
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
    
    return success;
}

#pragma mark - Update Contacts API -

- (BOOL)updateListOfContacts:(NSArray *)contacts {
    
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self updateContact:contact];
        
        if (!result) {
            
            NSLog(@"Failure to update the contacts");
            break;
        }
    }
    
    return result;
}

- (BOOL)updateContact:(ALContact *)contact {
    
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        userContact.userId = contact.userId;
        userContact.email = contact.email;
        userContact.fullName = contact.fullName;
        userContact.contactNo = contact.contactNumber;
        userContact.contactImageUrl = contact.contactImageUrl;
        userContact.unreadCount=contact.unreadCount;
        if(contact.displayName)
        {
            userContact.displayName = contact.displayName;
        }
        userContact.localImageResourceName = contact.localImageResourceName;
        
    }
    
    NSError *error = nil;
    
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;
}

-(BOOL)setUnreadCountDB:(ALContact*)contact{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    NSManagedObject* userCon = [result objectAtIndex:0];
    [userCon setValue:0 forKey:@"unreadCount"];
    
    NSError *error = nil;
    if (![dbHandler.managedObjectContext save:&error]) {
        
        NSLog(@"DB ERROR :%@",error);
        return NO;
    }
    
    return YES;
    
}

#pragma mark - Add Contacts API -

- (BOOL)addListOfContacts:(NSArray *)contacts {
    
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self addContact:contact];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (ALContact *) loadContactByKey:(NSString *) key value:(NSString*) value
{
    DB_CONTACT *dbContact = [self getContactByKey:key value:value];
    ALContact *contact = [[ALContact alloc] init];
    
    if (!dbContact) {
        contact.userId = value;
        contact.displayName = value;
        return contact;
    }
    contact.userId = dbContact.userId;
    contact.fullName = dbContact.fullName;
    contact.contactNumber = dbContact.contactNo;
    contact.displayName = dbContact.displayName;
    contact.contactImageUrl = dbContact.contactImageUrl;
    contact.email = dbContact.email;
    contact.localImageResourceName = dbContact.localImageResourceName;
    contact.connected = dbContact.connected;
    contact.lastSeenAt = dbContact.lastSeenAt;
    contact.unreadCount=dbContact.unreadCount;
    contact.block = dbContact.block;
    contact.blockBy = dbContact.blockBy;
    return contact;
}


- (DB_CONTACT *)getContactByKey:(NSString *) key value:(NSString*) value {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",key,value];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (result.count > 0) {
        DB_CONTACT* dbContact = [result objectAtIndex:0];
        /* ALContact *contact = [[ALContact alloc]init];
         contact.userId = dbContact.userId;
         contact.fullName = dbContact.fullName;
         contact.contactNumber = dbContact.contactNo;
         contact.displayName = dbContact.displayName;
         contact.contactImageUrl = dbContact.contactImageUrl;
         contact.email = dbContact.email;
         return contact;*/
        return dbContact;
    } else {
        return nil;
    }
}

-(BOOL)addContact:(ALContact *)userContact {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    DB_CONTACT* existingContact = [self getContactByKey:@"userId" value:[userContact userId]];
    if (existingContact) {
        return false;
    }
    
    
    BOOL result = NO;
    
    DB_CONTACT * contact = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    contact.userId = userContact.userId;
    
    contact.fullName = userContact.fullName;
    
    contact.contactNo = userContact.contactNumber;
    
    contact.displayName = userContact.displayName;
    
    contact.email = userContact.email;
    
    contact.contactImageUrl = userContact.contactImageUrl;
    
    contact.localImageResourceName =userContact.localImageResourceName;
    
    contact.unreadCount = userContact.unreadCount;

    NSError *error = nil;
    
    result = [dbHandler.managedObjectContext save:&error];
    
    if (!result) {
        NSLog(@"DB ERROR :%@",error);
    }
    
    return result;
}


-(void)addUserDetails:(NSMutableArray *)userDetails
{
//    NSMutableArray *userDetailArray = [[NSMutableArray alloc] init];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    for(ALUserDetail *theUserDetail in userDetails)
    {
        
        DB_CONTACT* existingContact = [self getContactByKey:@"userId" value:[theUserDetail userId]];
        if(existingContact!=nil){
            [self updateUserDetail:theUserDetail];
            continue;
        }
        
        DB_CONTACT *theUserDetailEntity = [self createUserDetailEntityForDBInsertionWithUserDetail:theUserDetail];
        [theDBHandler.managedObjectContext save:nil];
        theUserDetail.userDetailDBObjectId = theUserDetailEntity.objectID;
//        [userDetailArray addObject:theUserDetail];
        
    }
    
}

-(DB_CONTACT*) createUserDetailEntityForDBInsertionWithUserDetail:(ALUserDetail *) userDetail
{
     ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_CONTACT *theUserDetailEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CONTACT" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    theUserDetailEntity.userId = userDetail.userId;
    
    if(userDetail.displayName == nil)
    {
        theUserDetailEntity.displayName = userDetail.userId;
    }
    else
    {
        theUserDetailEntity.displayName = userDetail.displayName;
    }
    
    theUserDetailEntity.lastSeenAt =  userDetail.lastSeenAtTime;   //   [NSNumber numberWithInt:[userDetail.lastSeenAtTime doubleValue]];
    theUserDetailEntity.connected = userDetail.connected;
    theUserDetailEntity.unreadCount=[NSNumber numberWithInt:userDetail.unreadCount.intValue];
    theUserDetailEntity.contactImageUrl = userDetail.imageLink;
    return theUserDetailEntity;
}

-(void) updateConnectedStatus: (NSString *) userId lastSeenAt:(NSNumber *) lastSeenAt  connected: (BOOL) connected
{
    ALUserDetail *ob = [[ALUserDetail alloc]init];
    ob.lastSeenAtTime = lastSeenAt;
    ob.connected =  connected;
    ob.userId = userId;
    
    [self updateUserDetail:ob];
}

-(BOOL)updateUserDetail:(ALUserDetail *)userDetail
{
    BOOL success = NO;
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDetail.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {

        NSManagedObject *ob = [result objectAtIndex:0];
        
        [ob setValue: userDetail.lastSeenAtTime forKey:@"lastSeenAt"];
        [ob setValue:[NSNumber numberWithBool:userDetail.connected] forKey:@"connected"];
        [ob setValue:userDetail.unreadCount forKey:@"unreadCount"];
        if(userDetail.displayName)
        {
            [ob setValue:userDetail.displayName forKey:@"displayName"];
        }
        [ob setValue:userDetail.imageLink forKey:@"contactImageUrl"];
        
    }
    else
    {
         // Add contact in DB.
         ALContact * contact = [[ALContact alloc] init];
         contact.userId =userDetail.userId;
         contact.unreadCount= userDetail.unreadCount;
         contact.lastSeenAt = [NSNumber numberWithBool:userDetail.connected];
         contact.displayName = userDetail.displayName;
        [self addContact:contact];
    }
    
    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;

}
-(BOOL)updateLastSeenDBUpdate:(ALUserDetail *)userDetail{
    BOOL success = NO;
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDetail.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        
        NSManagedObject *ob = [result objectAtIndex:0];
        
        [ob setValue: userDetail.lastSeenAtTime forKey:@"lastSeenAt"];
        
    }
    
    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;
}
-(NSUInteger)markConversationAsDeliveredAndRead:(NSString*)contactId
{
    NSArray *messages =  [self getUnreadMessagesForIndividual:contactId];
    if(messages.count >0 ){
        NSBatchUpdateRequest *req= [[NSBatchUpdateRequest alloc] initWithEntityName:@"DB_Message"];
        req.predicate = [NSPredicate predicateWithFormat:@"contactId==%@ and groupId=0",contactId];
        req.propertiesToUpdate = @{
                                   @"status" : @(DELIVERED_AND_READ)
                                   };
        req.resultType = NSUpdatedObjectsCountResultType;
        ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
        NSBatchUpdateResult *res = (NSBatchUpdateResult *)[dbHandler.managedObjectContext executeRequest:req error:nil];
        NSLog(@"%@ objects updated", res.result);
    }
    return messages.count;
}

- (NSArray *)getUnreadMessagesForIndividual:(NSString *)contactId {
    
    //Runs at Opening AND Leaving ChatVC AND Opening MessageList..
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate;
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status != %i AND type==%@ ",DELIVERED_AND_READ,@"4"];
    
    if (contactId) {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K=%@",@"contactId",contactId];
        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"groupId==%d OR groupId==%@",0,NULL];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2,predicate3]];
    } else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2]];
    }
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    return result;
}

-(BOOL)setBlockUser:(NSString *)userId andBlockedState:(BOOL)flag
{
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        DB_CONTACT *resultDBContact = [result objectAtIndex:0];
        resultDBContact.block = flag;
    }

    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success)
    {
        NSLog(@"DB ERROR FOR BLOCKING/UNBLOCKING USER %@ :%@",userId, error);
    }
    return success;
}

-(void)blockAllUserInList:(NSMutableArray *)userList
{
    for(ALUserBlocked *userBlocked in userList)
    {
        [self setBlockUser:userBlocked.blockedTo andBlockedState:userBlocked.userBlocked];
    }
}

-(void)blockByUserInList:(NSMutableArray *)userList
{
    for(ALUserBlocked *userBlocked in userList)
    {
        [self setBlockByUser:userBlocked.blockedBy andBlockedByState:userBlocked.userblockedBy];
    }
}

-(BOOL)setBlockByUser:(NSString *)userId andBlockedByState:(BOOL)flag
{
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        DB_CONTACT *resultDBContact = [result objectAtIndex:0];
        resultDBContact.blockBy = flag;
    }
    
    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success)
    {
        NSLog(@"DB ERROR FOR BLOCKED BY USER %@ :%@", userId, error);
    }
    return success;
}

-(NSMutableArray *)getListOfBlockedUsers
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * userList = [[NSMutableArray alloc] init];
    
    if(array.count)
    {
        for(DB_CONTACT *contact in array)
        {
            if(contact.block)
            {
                [userList addObject:contact.userId];
            }
        }
    }
    else
    {
        NSLog(@"NO BLOCKED USER FOUND");
    }
    
    return userList;
}

@end
