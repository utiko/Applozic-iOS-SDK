//
//  ALVCardClass.m
//  Applozic
//
//  Created by Abhishek Thapliyal on 9/21/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALVCardClass.h"
#import "ALUtilityClass.h"

@implementation ALVCardClass

-(NSString *)saveContactToDocDirectory:(CNContact *)contact
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * vcfCARDPath = [documentsDirectory stringByAppendingString:
                              [NSString stringWithFormat:@"/CONTACT_%f_CARD.vcf",[[NSDate date] timeIntervalSince1970] * 1000]];
    
    NSArray *array = [[NSArray alloc] initWithObjects:contact, nil];
    
    NSError *errorVCFCARD;
    NSData *data = [CNContactVCardSerialization dataWithContacts:array error:&errorVCFCARD];
    [data writeToFile:vcfCARDPath atomically:YES];
    NSLog(@"ERROR_IF_ANY WHILE SAVING VCF FILE :: %@",errorVCFCARD.description);
    return vcfCARDPath;
}

-(void)vCardParser:(NSString *)filePath
{
    NSData *dataString = [NSData dataWithContentsOfFile:filePath];
    NSError *errorVCF;
    NSArray *contactList = [NSArray arrayWithArray:[CNContactVCardSerialization contactsWithData:dataString error:&errorVCF]];
    
    NSLog(@"ERROR_IF_ANY :: %@", errorVCF);
    
    if(contactList.count == 0)
    {
        return;
    }
    
    CNContact *contactObject = [contactList objectAtIndex:0];
    
    self.alCNContact = contactObject;
//    self.fullName = [contactObject.givenName stringByAppendingString:contactObject.familyName];
    self.fullName = [NSString stringWithFormat:@"%@ %@", contactObject.givenName, contactObject.familyName];
    
    if(contactObject.imageData)
    {
        self.contactImage = [[UIImage alloc] initWithData:contactObject.imageData];
    }
    
    NSString * phone = @"";
    for(CNLabeledValue *phonelabel in contactObject.phoneNumbers)
    {
        CNPhoneNumber *phoneNo = phonelabel.value;
        phone = [phoneNo stringValue];
        if (phone)
        {
            self.userPHONE_NO = phone;
        }
    }
    
    NSString * email = @"";
    for(CNLabeledValue *emaillabel in contactObject.emailAddresses)
    {
        email = emaillabel.value;
        if (email)
        {
            self.userEMAIL_ID = email;
        }
    }
}

-(void)addContact:(ALVCardClass *)alVcard
{
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
    
    mutableContact.givenName = alVcard.fullName;
    mutableContact.imageData = UIImagePNGRepresentation(alVcard.contactImage);
    mutableContact.phoneNumbers = [NSArray arrayWithArray:alVcard.alCNContact.phoneNumbers];
    mutableContact.emailAddresses = [NSArray arrayWithArray:alVcard.alCNContact.emailAddresses];
    
    [saveRequest addContact:mutableContact toContainerWithIdentifier:nil];
    
    NSError * error;
    [store executeSaveRequest:saveRequest error:&error];
    
    if(error)
    {
        NSLog(@"ERROR_SAVING_NEW_CONTACT : %@", error);
        return;
    }
    
    [ALUtilityClass showAlertMessage:@"Contact saved sucessfully" andTitle:@"CONTACT"];
    
}


@end
