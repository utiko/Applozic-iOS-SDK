//
//  ALVCardClass.m
//  Applozic
//
//  Created by devashish on 24/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALVCardClass.h"

@implementation ALVCardClass

-(NSString *)saveContactToDocDirectory:(CNContact *)contact
{
    NSString *vCardString = [self genrateVCardString:contact];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * tempPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/CONTACT_%f_CARD.vcf",[[NSDate date] timeIntervalSince1970] * 1000]];
    
    NSData* data = [vCardString dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:tempPath atomically:YES];
    
//    NSArray <CNContact *>*contactArray = [NSArray new];
//    [contactArray arrayByAddingObject:contact];
//    NSData* data = [CNContactVCardSerialization dataWithContacts:contactArray error:nil];
//    [data writeToFile:tempPath atomically:YES];
//    
    NSLog(@"VCF_FILE_PATH : %@",tempPath);
    return tempPath;
}

-(NSString *)genrateVCardString:(CNContact *)contact
{
    NSString *vCardStringData;
    vCardStringData = @"BEGIN:VCARD\nVERSION:3.0\n";
    NSString * name = [NSString stringWithFormat:@"N:%@;%@;",(contact.nickname ? contact.nickname : @""), (contact.namePrefix ? contact.namePrefix : @"")];
    NSString * fullname = [NSString stringWithFormat:@"FN:%@ %@;",(contact.givenName ? contact.givenName : @""), (contact.familyName ? contact.familyName : @"")];
    
    NSString *phNumber = @"";
    NSString * phone = @"";
    for(CNLabeledValue *phonelabel in contact.phoneNumbers)
    {
        CNPhoneNumber *phoneNo = phonelabel.value;
        phone = [phoneNo stringValue];
        if (phone)
        {
            phNumber = [phNumber stringByAppendingString:[NSString stringWithFormat:@"TEL;CELL:%@\n", phone]];
        }
    }
    
    NSString * emailId = @"";
    NSString * email = @"";
    for(CNLabeledValue *emaillabel in contact.emailAddresses)
    {
        email = (NSString *)emaillabel.value;
        if (email)
        {
            emailId = [emailId stringByAppendingString:[NSString stringWithFormat:@"EMAIL:%@;\n", email]];
        }
    }
    
    NSString *imageStringBASE64 = [contact.imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
//    NSString *imageStringBASE64 = [contact.imageData base64Encoding];

//    UIImage *image = [UIImage imageWithData:contact.imageData];
//    NSString *imageStringBASE64 = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
//    UIImage *image = [UIImage imageWithData:contact.imageData];
//    NSData *comData = UIImageJPEGRepresentation(image, 0.5f);
//    NSString *imageStringBASE64  = [comData base64EncodedStringWithOptions:0];
    
    imageStringBASE64 = [NSString stringWithFormat:@"PHOTO;ENCODING=BASE64;JPEG:%@", imageStringBASE64];
    
    vCardStringData = [vCardStringData stringByAppendingString:[NSString stringWithFormat:@"%@\n%@\n%@%@%@\n",
                                                                name,
                                                                fullname,
                                                                phNumber,
                                                                emailId,
                                                                imageStringBASE64]];
    
    vCardStringData = [vCardStringData stringByAppendingString:@"END:VCARD"];
    
//    NSLog(@"VCARD_FINAL_STRING %@",vCardStringData);
    
    return vCardStringData;
}

-(void)vCardParser:(NSString *)filePath
{
    NSData *dataString = [NSData dataWithContentsOfFile:filePath];
    NSArray *contactList = [NSArray arrayWithArray:[CNContactVCardSerialization contactsWithData:dataString error:nil]];

//    NSLog(@"CONTACT_ARRAY %@",contactList);
//    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"CONTACT_FILE_STRING : ====================== \n %@ \n ====================",content);
    
    if(contactList.count == 0)
    {
        return;
    }
    CNContact *contactObject = [contactList objectAtIndex:0];
    self.alCNContact = contactObject;
    self.fullName = [contactObject.familyName stringByAppendingString:contactObject.givenName];
    
    //    self.contactImage = [[UIImage alloc] initWithData:contactObject.imageData];
    //    self.contactImage = [UIImage imageWithData:contactObject.imageData];
    
    NSData *dataVCard = [[NSData alloc] initWithBase64EncodedData:contactObject.imageData options:0];   //NSDataBase64DecodingIgnoreUnknownCharacters
    self.contactImage = [[UIImage alloc] initWithData:dataVCard];
    
//    NSLog(@"DATA_IMAGE PARSER :%@ %i",contactObject.imageData,contactObject.imageDataAvailable);
//    NSLog(@"DATA_IMAGE AFTER PARSE :%@",self.contactImage);
    
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
    CNContactStore *store = [CNContactStore new];
    CNSaveRequest *saveRequest = [CNSaveRequest new];
    CNMutableContact *mutableContact = [CNMutableContact new];
    
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CONTACT" message:@"NEW CONTACT SAVED SUCCESFULLY" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];

}

@end
