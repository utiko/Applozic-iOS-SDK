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
@property (nonatomic,strong) NSNumber* chatLauncherFLAG;

-(instancetype)initWithApplicationId:(NSString *) applicationId;
-(void)ALDefaultChatViewSettings;

-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text;

-(void)launchChatList:(NSString *)title andViewControllerObject:(UIViewController *)viewController;

-(void) launchContactList: (UIViewController *)uiViewController ;
-(void)registerForNotification;

-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID withDisplayName:(NSString*)displayName andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text;





@end