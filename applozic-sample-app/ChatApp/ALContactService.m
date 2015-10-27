//
//  ALContactService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactService.h"
#import "ALContactDBService.h"

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



/*
  Helper method for demo purpose
 */
- (void) insertInitialContacts{

    // contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"111";
    contact1.fullName = @"Adarsh Kumar";
    contact1.contactNumber = @"1234561234";
    contact1.displayName = @"Adarsh";
    contact1.email = @"123@abc.com";
    contact1.contactImageUrl = @" http://www.applozic.com/resources/images/applozic_logo.gif";
    
    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"222";
    contact2.fullName = @"Abhishek Thapiyal";
    contact2.contactNumber = @"9876512340";
    contact2.displayName = @"Navneet";
    contact2.email = @"456@abc.com";
    contact2.contactImageUrl = nil;
    
    // contact 3
    ALContact *contact3 = [[ALContact alloc] init];
    contact3.userId = @"applozic";
    contact3.fullName = @"Applozic";
    contact3.contactNumber = @"9535008745";
    contact3.displayName = @"Applozic";
    contact3.email = @"devashish@applozic.com";
    contact3.contactImageUrl = nil;
    
    //From json....
    
//    NSString * jsonString = @"{
//    "userId":"adarshk",
//    "fullName":"Adarsh kumar",
//    "contactNumber":"9742689004",
//    "displayName":"Adarsh",
//    "contactImageUrl":"http://www.applozic.com/resources/images/applozic_logo.gif",
//    "email":"adarsh@applozic.com"
//    "localImageResourceName":"abcdEfgh"
//}"
//    
    [self addListOfContacts:@[contact1,contact2,contact3]];
}

/*
 */




@end
