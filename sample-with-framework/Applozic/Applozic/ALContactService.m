//
//  ALContactService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactService.h"
#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALUserService.h"

@implementation ALContactService

 ALContactDBService * alContactDBService;

-(instancetype)  init{
    self= [super init];
    alContactDBService = [[ALContactDBService alloc]init];
    return self;
}

#pragma mark Deleting APIS


//For purgeing single contacts

-(BOOL)purgeContact:(ALContact *)contact{
    
    return [ alContactDBService purgeContact:contact];
}


//For purgeing multiple contacts
-(BOOL)purgeListOfContacts:(NSArray *)contacts{
    
    return [ alContactDBService purgeListOfContacts:contacts];
}


//For delting all contacts at once

-(BOOL)purgeAllContacts{
  return  [alContactDBService purgeAllContacts];
    
}

#pragma mark Update APIS


-(BOOL)updateContact:(ALContact *)contact{
    return [alContactDBService updateContact:contact];
    
}


-(BOOL)updateListOfContacts:(NSArray *)contacts{
    return [alContactDBService updateListOfContacts:contacts];
}


#pragma mark addition APIS


-(BOOL)addListOfContacts:(NSArray *)contacts{
    return [alContactDBService updateListOfContacts:contacts];

}

-(BOOL)addContact:(ALContact *)userContact{
    return [alContactDBService addContact:userContact];

}

#pragma mark fetching APIS


- (ALContact *)loadContactByKey:(NSString *) key value:(NSString*) value{
    return [alContactDBService loadContactByKey:key value:value];

}

#pragma mark fetching OR SAVE with Serevr call...


- (ALContact *)loadOrAddContactByKeyWithDisplayName:(NSString *) contactId value:(NSString*) displayName{
    
    DB_CONTACT *dbContact = [alContactDBService getContactByKey:@"userId" value:contactId];
    
    ALContact *contact = [[ALContact alloc]init];
    if (!dbContact) {
        contact.userId = contactId;
        contact.displayName = displayName;
        [self addContact:contact];
        [ ALUserService updateUserDisplayName:contact];
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
    return contact;
}



-(void)insertInitialContactsService:(NSArray*)demoContactsArray{

    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    [theDBHandler addListOfContacts:demoContactsArray];

}

@end
