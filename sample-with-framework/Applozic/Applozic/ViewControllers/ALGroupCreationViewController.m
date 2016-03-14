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
#import "ALChatViewController.h"

@interface ALGroupCreationViewController ()
@property (nonatomic,retain) UIImagePickerController * mImagePicker;
@end

@implementation ALGroupCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *nextContacts = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(launchContactSelection:)];
    self.navigationItem.rightBarButtonItem = nextContacts;
    self.automaticallyAdjustsScrollViewInsets=NO; //setting to NO helps show UITextView's text at view load
    [self setupGroupIcon:self.groupIconView];
    self.mImagePicker = [[UIImagePickerController alloc] init];
    self.mImagePicker.delegate = self;
   
}

-(void)viewWillAppear:(BOOL)animated{
    [self.groupNameInput becomeFirstResponder];
    self.descriptionTextView.hidden=NO;
    self.descriptionTextView.userInteractionEnabled=NO;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)launchContactSelection:(id)sender {
    
    
//    Check if group name text is empty
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
    
    
//    Moving forward to member selection
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALGroupCreationViewController.class]];
    UIViewController *groupCreation = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];

//    Setting groupName and forGroup flag
    ((ALNewContactsViewController*)groupCreation).forGroup=[NSNumber numberWithInt:GROUP_CREATION];
    ((ALNewContactsViewController*)groupCreation).groupName=self.groupNameInput.text;
    
//    Moving to contacts view for group member selection
    [self.navigationController pushViewController:groupCreation animated:YES];
}

#pragma mark - Group Icon setup and events

-(void)setupGroupIcon:(UIImageView *)groupIconView{
    groupIconView.clipsToBounds=YES;
    groupIconView.layer.cornerRadius=self.groupIconView.frame.size.width/2;
    groupIconView.layer.borderColor =[UIColor lightGrayColor].CGColor;
    [self groupIconViewTap:groupIconView];
}

-(void)groupIconViewTap:(UIImageView*)groupIconView{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGallery)];
    singleTap.numberOfTapsRequired = 1;
    [groupIconView setUserInteractionEnabled:YES];
    [groupIconView addGestureRecognizer:singleTap];
}
-(void)openGallery{
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
}

#pragma mark - image picker delegates

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image getCompressedImageLessThanSize:5];
    [self.groupIconView setImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
// TextView     = 100
// ImageView    = 102
// Text Field   = 103
