//
//  ALGroupCreationViewController.m
//  Applozic
//
//  Created by Divjyot Singh on 13/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

//groupNameInput
//groupIcon

#import "ALGroupCreationViewController.h"
#import "ALNewContactsViewController.h"

@implementation ALGroupCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *nextContacts = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(launchContactSelection:)];
    self.navigationItem.rightBarButtonItem = nextContacts;
    self.automaticallyAdjustsScrollViewInsets=NO; //it helps show UITextView text at view load
}

-(void)viewWillAppear:(BOOL)animated{
    [self.groupNameInput becomeFirstResponder];
    self.descriptionTextView.hidden=NO;
    self.descriptionTextView.userInteractionEnabled=NO;
    
}
- (void)launchContactSelection:(id)sender {
    
    
    //Check if group name text is empty
    if([self.groupNameInput.text isEqualToString:@""]){
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Group Name"
                                              message:@"Please give the group name."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    
    //Moving forward to member selection
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALGroupCreationViewController.class]];
    UIViewController *groupCreation = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];

    //Setting groupName and forGroup flag
    ((ALNewContactsViewController*)groupCreation).forGroup=[NSNumber numberWithBool:YES];
    ((ALNewContactsViewController*)groupCreation).groupName=self.groupNameInput.text;
    
    //Moving to contacts view for group member selection
    [self.navigationController pushViewController:groupCreation animated:YES];
}

@end
// TextView     = 100
// ImageView    = 102
// Text Field   = 103
