//
//  ALUserInformationViewController.h
//  Applozic
//
//  Created by devashish on 16/05/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALContact.h"

@interface ALUserInformationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView * userTableView;
@property (strong, nonatomic) ALContact * alContact;
@property (strong, nonatomic) NSMutableDictionary * userDetailDictionary;
@property (strong, nonatomic) NSArray * keys;

-(void)genearateDictionary;

@end
