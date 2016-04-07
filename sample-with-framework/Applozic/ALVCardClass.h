//
//  ALVCardClass.h
//  Applozic
//
//  Created by devashish on 24/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
@import Contacts;


@interface ALVCardClass : NSObject

@property (nonatomic, strong) UIImage * contactImage;
@property (nonatomic, strong) NSString * fullName;
@property (nonatomic, strong) NSString * userPHONE_NO;
@property (nonatomic, strong) NSString * userEMAIL_ID;

@property (nonatomic, strong) CNContact * alCNContact;

-(NSString *)saveContactToDocDirectory:(CNContact *)contact;
-(NSString *)genrateVCardString:(CNContact *)contact;
-(void)vCardParser:(NSString *)filePath;
-(void)addContact:(ALVCardClass *)alVcard;

@end
