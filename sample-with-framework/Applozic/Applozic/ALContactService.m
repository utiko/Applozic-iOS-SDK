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
    //TODO: Update with valid contacts.
    // adding default data
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    // contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"adarshk";
    contact1.fullName = @"Rathan";
    contact1.contactNumber = @"1234561234";
    contact1.displayName = @"Rathan";
    contact1.email = @"123@abc.com";
    // contact1.contactImageUrl = @"http://applozic.com/resources/images/aboutus/rathan.jpg";
    contact1.contactImageUrl = nil;
    contact1.localImageResourceName = @"4.jpg";
    
    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"marvel";
    contact2.fullName = @"abhishek thapliyal";
    contact2.contactNumber = @"987651234";
    contact2.displayName = @"abhishek";
    contact2.email = @"456@abc.com";
    contact2.contactImageUrl = nil;
    contact2.localImageResourceName = @"4.jpg";
    
    // contact 3
    ALContact *contact3 = [[ALContact alloc] init];
    contact3.userId = @"applozic";
    contact3.fullName = @"Applozic";
    contact3.contactNumber = @"9535008745";
    contact3.displayName = @"Applozic";
    contact3.email = @"devashish@applozic.com";
    contact3.contactImageUrl = nil;
    //  contact3.contactImageUrl = @"http://applozic.com/resources/images/aboutus/rathan.jpg";
    contact3.localImageResourceName = @"1.jpg";
    
    ALContact *contact4 = [[ALContact alloc] init];
    contact4.userId = @"don";
    contact4.fullName = @"DON";
    contact4.contactNumber = @"1299834";
    contact4.displayName = @"DON";
    contact4.email = @"don@baba.com";
    contact4.contactImageUrl = @"http://tinyhousetalk.com/wp-content/uploads/320-Sq-Ft-Orange-Container-Guest-House-00.jpg";
    contact4.localImageResourceName = nil;
    
    NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init];
    [demodictionary setValue:@"aman999" forKey:@"userId"];
    [demodictionary setValue:@"aman sharma" forKey:@"fullName"];
    [demodictionary setValue:@"75760462" forKey:@"contactNumber"];
    [demodictionary setValue:@"aman" forKey:@"displayName"];
    [demodictionary setValue:@"aman@applozic.com" forKey:@"email"];
    [demodictionary setValue:@"http://images.landofnod.com/is/image/LandOfNod/Letter_Giant_Enough_A_231533_LL/$web_zoom$&wid=550&hei=550&/1308310656/not-giant-enough-letter-a.jpg" forKey:@"contactImageUrl"];
    [demodictionary setValue:nil forKey:@"localImageResourceName"];
    
    ALContact *contact5 = [[ALContact alloc] initWithDict:demodictionary];
    
    [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact4, contact5]];
   
}






@end
