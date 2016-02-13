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
    
    UIBarButtonItem *nextContacts = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(launchContactSelection:)];
    self.navigationItem.rightBarButtonItem = nextContacts;
//     self.descriptionTextView.text=@"Please provide group name along with optional group icon";
}

-(void)viewWillAppear:(BOOL)animated{
    [self.groupNameInput becomeFirstResponder];
    self.descriptionTextView.hidden=NO;
    self.descriptionTextView.userInteractionEnabled=NO;
    
}
- (void)launchContactSelection:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALGroupCreationViewController.class]];
    UIViewController *groupCreation = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    ((ALNewContactsViewController*)groupCreation).forGroup=[NSNumber numberWithBool:YES];
    [self.navigationController pushViewController:groupCreation animated:YES];
}

@end


// TextView     = 100
// ImageView    = 102
// Text Field   = 103


//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    return 2;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//
//    if(section==0){
//
//        return 1;
//    }
//    else if (section==1){
//
//        return 1;
//    }
//    else{
//        return 0;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    static NSString *cellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    UITextView* despTextView=(UITextView*)[cell viewWithTag:100];
//    [despTextView becomeFirstResponder];
////    UIImageView* groupImageView=(UIImageView*)[cell viewWithTag:102];
//    UITextField* inputGroupName=(UITextField*)[cell viewWithTag:103];
//
//    switch (indexPath.section) {
//
//        case 0:{
//
////            [despTextView setFrame:CGRectMake(self.mTableView.frame.origin.x+10,
////                                              self.mTableView.frame.origin.y+10,
////                                              150,
////                                              50)];
////
////
////            [groupImageView setFrame:CGRectMake(self.mTableView.frame.size.width-150,
////                                                tableView.frame.origin.y-5,
////                                                150,
////                                                50)];
//
//
//            [cell addSubview:despTextView];
////            [cell addSubview:groupImageView];
//            inputGroupName.hidden=YES;
//
//        }break;
//
//        case 1:{
//
////            [inputGroupName setFrame:CGRectMake(15,
////                                                26,
////                                                485,
////                                                30)];
//            [cell addSubview:inputGroupName];
//            despTextView.hidden=YES;
////            groupImageView.hidden=YES;
//
//        }break;
//        default:
//            return 0;
//            break;
//    }
//    return cell;
//}
//
////- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
////
////    if(indexPath.row == 0){
////        tableView.rowHeight=40.0;
////    }
////    else{
////        tableView.rowHeight=81.5;
////    }
////
////    return tableView.rowHeight;
////}
//
