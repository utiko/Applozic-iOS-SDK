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

-(BOOL)purgeAllContact{
  return  [alContactDBService purgeAllContact];
    
}

#pragma mark Update APIS


-(BOOL)updateConatct:(ALContact *)contact{
    return [alContactDBService updateConatct:contact];
    
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

//----------------------------------------------------------------------------------------------------------------------
// Helper method for demo purpose. This method shows possible ways to insert contact and save it in local database.
//----------------------------------------------------------------------------------------------------------------------

- (void) insertInitialContacts{

    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    //contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"adarshk";
    contact1.fullName = @"Rathan";
    contact1.contactNumber = @"1234561234";
    contact1.displayName = @"Rathan";
    contact1.email = @"123@abc.com";
    contact1.contactImageUrl = nil;
    contact1.localImageResourceName = @"1.jpg";
    contact1.applicationId = [ALUserDefaultsHandler getApplicationKey];
    
    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"marvel";
    contact2.fullName = @"abhishek thapliyal";
    contact2.contactNumber = @"987651234";
    contact2.displayName = @"abhishek";
    contact2.email = @"456@abc.com";
    contact2.contactImageUrl = nil;
    contact2.localImageResourceName = @"1.jpg";
    contact2.applicationId = [ALUserDefaultsHandler getApplicationKey];
    
    ALContact *contact3 = [[ALContact alloc] init];
    contact3.userId = @"don";
    contact3.fullName = @"DON";
    contact3.contactNumber = @"1299834";
    contact3.displayName = @"DON";
    contact3.email = @"don@baba.com";
    contact3.contactImageUrl = @"http://tinyhousetalk.com/wp-content/uploads/320-Sq-Ft-Orange-Container-Guest-House-00.jpg";
    contact3.localImageResourceName = nil;
    contact3.applicationId = [ALUserDefaultsHandler getApplicationKey];

    
    //Contact -------- Example with json
    
//    NSString *jsonString =@"{\"userId\": \"applozic\",\"fullName\": \"Applozic\",\"contactNumber\": \"9535008745\",\"displayName\": \"Applozic Support\",\"contactImageUrl\": \"http://applozic.com/resources/images/aboutus/rathan.jpg\",\"email\": \"devashish@applozic.com\",\"localImageResourceName\":null}";
//    
//    ALContact *contact4 = [[ALContact alloc] initWithJSONString:jsonString];
//
//    //Contact ------- Example with dictonary
    
    NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init];
    [demodictionary setValue:@"aman999" forKey:@"userId"];
    [demodictionary setValue:@"aman sharma" forKey:@"fullName"];
    [demodictionary setValue:@"75760462" forKey:@"contactNumber"];
    [demodictionary setValue:@"aman" forKey:@"displayName"];
    [demodictionary setValue:@"aman@applozic.com" forKey:@"email"];
    [demodictionary setValue:@"http://images.landofnod.com/is/image/LandOfNod/Letter_Giant_Enough_A_231533_LL/$web_zoom$&wid=550&hei=550&/1308310656/not-giant-enough-letter-a.jpg" forKey:@"contactImageUrl"];
    [demodictionary setValue:nil forKey:@"localImageResourceName"];
    [demodictionary setValue:[ALUserDefaultsHandler getApplicationKey] forKey:@"applicationId"];
    
    ALContact *contact5 = [[ALContact alloc] initWithDict:demodictionary];
 //   [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact4, contact5]];
    [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact5]];
   
}

@end
