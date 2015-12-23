//
//  MBChatManager.h
//  Applozic
//
//  Created by devashish on 21/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MBChatManager : NSObject

-(void)mbChatViewSettings;
-(void)launchIndividualChat:(NSString *)userId andViewControllerObject:(UIViewController *)viewController;
-(void)launchChatList:(NSString *)userId andWithBackButtonTitle:(NSString *)title andViewControllerObject:(UIViewController *)viewController;

-(void)launchChatForUser:(NSString* )userId fromViewController:(UIViewController*)viewController;
-(void)launchChatForUser:(NSString*)userId andWithEmailId:(NSString*)emailId fromViewController:(UIViewController*)viewController;

@end
