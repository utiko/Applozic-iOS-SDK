//
//  ALContactDBService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactDBService.h"
#import "ALDBHandler.h"

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
        
        result = [self updateConatct:contact];
        
        if (!result) {
            
            NSLog(@"Failure to update the contacts");
            break;
        }
    }
    
    return result;
}

- (BOOL)updateConatct:(ALContact *)contact {
    
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
        userContact.displayName = contact.displayName;
        userContact.localImageResourceName = contact.localImageResourceName;
        
    }
    
    NSError *error = nil;
    
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;
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

- (ALContact *) loadContactByKey:(NSString *) key value:(NSString*) value {
    DB_CONTACT *dbContact = [self getContactByKey:key value:value];
    ALContact *contact = [[ALContact alloc]init];
    
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
        NSLog(@"Existing contact");
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
    
    NSError *error = nil;
    
    result = [dbHandler.managedObjectContext save:&error];
    
    if (!result) {
        NSLog(@"DB ERROR :%@",error);
    }
    
    return result;
}


-(void)addUserDetails:(NSMutableArray *)userDetails
{
   // NSMutableArray *userDetailArray = [[NSMutableArray alloc] init];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    for(ALUserDetail *theUserDetail in userDetails)
    {
        
        DB_CONTACT* existingContact = [self getContactByKey:@"userId" value:[theUserDetail userId]];
        
        if(existingContact!=nil)
        {
            [self updateUserDetail:theUserDetail];
            continue;
        }
        
        DB_CONTACT *theUserDetailEntity = [self createUserDetailEntityForDBInsertionWithUserDetail:theUserDetail];
        
        
        [theDBHandler.managedObjectContext save:nil];
        theUserDetail.userDetailDBObjectId = theUserDetailEntity.objectID;
       // [userDetailArray addObject:theUserDetail];
        
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
    
    theUserDetailEntity.lastSeenAt = [NSNumber numberWithInt:[userDetail.lastSeenAtTime doubleValue]];
    theUserDetailEntity.connected = userDetail.connected;
    
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
    
    if(result.count>0)
    {

        NSManagedObject *ob = [result objectAtIndex:0];
        [ob setValue: userDetail.lastSeenAtTime forKey:@"lastSeenAt"];
        [ob setValue:[NSNumber numberWithBool:userDetail.connected] forKey:@"connected"];
    }
    NSError *error = nil;
    
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;

}

@end
