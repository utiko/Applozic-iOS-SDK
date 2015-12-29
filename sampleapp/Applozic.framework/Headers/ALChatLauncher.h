//

//  MBChatManager.h

//  Applozic

//

//  Created by devashish on 21/12/2015.

//  Copyright © 2015 applozic Inc. All rights reserved.

//



#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>



@interface ALChatLauncher : NSObject



@property(nonatomic,assign) NSString* applicationId;

-(instancetype)initWithApplicationId:(NSString *) applicationId;
-(void)ALDefaultChatViewSettings;

-(void)launchIndividualChat:(NSString *)userId andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text;
-(void)launchChatList:(NSString *)title andViewControllerObject:(UIViewController *)viewController;


-(void)registerForNotification;



@end