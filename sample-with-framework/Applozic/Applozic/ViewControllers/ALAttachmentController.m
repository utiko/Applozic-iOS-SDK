//
//  ALImageWithTextController.m
//  ChatApp
//
//  Created by devashish on 31/10/2015.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALAttachmentController.h"

@interface ALAttachmentController ()

@end

@implementation ALAttachmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pickedImageView setImage:self.imagedocument];
    self.textMessageWithImage.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    
    if([ALApplozicSettings getColourForNavigation] && [ALApplozicSettings getColourForNavigationItem])
    {
        self.navigationController.navigationBar.translucent = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColourForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColourForNavigationItem]];
        [self.navigationController.navigationBar setBackgroundColor: [ALApplozicSettings getColourForNavigation]];
    }
    
    self.textMessageWithImage.layer.masksToBounds = YES;
    self.textMessageWithImage.layer.borderColor = [[UIColor brownColor] CGColor];
    self.textMessageWithImage.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendButtonAction:(id)sender {
 
    [self.imagecontrollerDelegate check:self.imagedocument andText:self.textMessageWithImage.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setImageViewMethod:(UIImage *)image {
    self.imagedocument = image;
}

//==========================================
#pragma mark - Text Field Delegate
//==========================================s

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [self.textMessageWithImage resignFirstResponder];
    return  YES;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch=[[event allTouches] anyObject];
    if([self.textMessageWithImage isFirstResponder]&&[touch view]!=self.textMessageWithImage){
        [self.textMessageWithImage resignFirstResponder];
        
    }
}

-(void) viewDidDisappear:(BOOL)animated{

}

@end
