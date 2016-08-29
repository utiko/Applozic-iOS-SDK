//
//  LaunchChatFromSimpleViewController.h
//  applozicdemo
//
//  Created by Devashish on 13/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Applozic/Applozic.h>

@interface LaunchChatFromSimpleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *launchChatList;
@property(nonatomic,strong) UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet UIButton *launchTabBar;

- (IBAction)launchTabBarAction:(id)sender;
@end
