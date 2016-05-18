//
//  ALSettingsForDebug.m
//  applozicdemo
//
//  Created by Divjyot Singh on 16/05/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALSettingsForDebug.h"
#import  <Applozic/ALChatViewController.h>
#import "DemoChatManager.h"
#import "ApplozicLoginViewController.h"
#import  <Applozic/ALUserDefaultsHandler.h>
#import  <Applozic/ALRegisterUserClientService.h>
#import  <Applozic/ALDBHandler.h>
#import  <Applozic/ALContact.h>
#import  <Applozic/ALDataNetworkConnection.h>
#import  <Applozic/ALMessageService.h>

@interface ALSettingsForDebug () <UITextFieldDelegate>

@end

@implementation ALSettingsForDebug

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moduleIDTextField.delegate = self;

    
    if([ALApplozicSettings getContextualChatOption]){
        [self.contextualChatSwitchOutlet setOn:YES];
    }else{
        [self.contextualChatSwitchOutlet setOn:NO];
    }
    
    if([[ALApplozicSettings getChatWallpaperImageName] isEqualToString:@"NULL"]){
         [self.backWallaperSwitchOutlet setOn:NO];
    }else{
        [self.backWallaperSwitchOutlet setOn:YES];
    }
}

- (IBAction)setContextualChatSwitch:(id)sender {
    if(self.contextualChatSwitchOutlet.on){
        [ALApplozicSettings setContextualChat:YES];
    }else{
        [ALApplozicSettings setContextualChat:NO];
    }
}

- (IBAction)backgroundWallaperSwitchAction:(id)sender {
    if(self.backWallaperSwitchOutlet.on){
     [ALApplozicSettings setChatWallpaperImageName:@"wallpaper.png"];
    }
    else{
        [ALApplozicSettings setChatWallpaperImageName:@"NULL"];
    }
}
- (IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if(![textField.text isEqualToString:@""]){
        NSLog(@"Module ID TextField :%@",self.moduleIDTextField.text);
        [ALUserDefaultsHandler setAppModuleName:self.moduleIDTextField.text];
    }
    return YES;
}

@end



//    [ALApplozicSettings setContextualChat:YES];
