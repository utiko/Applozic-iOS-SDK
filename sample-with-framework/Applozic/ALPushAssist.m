 //
//  ALPushAssist.m
//  Applozic
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALPushAssist.h"

#import "ALPushNotificationService.h"
#import "ALMessageDBService.h"
#import "ALUserDetail.h"
#import "ALUserDefaultsHandler.h"
#import "ALChatViewController.h"
#import "ALMessagesViewController.h"


@implementation ALPushAssist


-(void)notificaitionShow{
//    [[[UIApplication sharedApplication] keyWindow] addSubview:someView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextP)
                                                 name:@"pushNotification"
                                               object:nil];
}


-(void)contextP:(NSNotification*)notif{
    ALChatViewController* obj=[[ALChatViewController alloc] init];
    [obj individualNotificationhandler:notif];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:@"pushNotification"];
}


-(void)assist{

   
    NSLog(@"Top View>>>> %@",self.topViewController.title);

    if ([self.topViewController isKindOfClass:[ALMessagesViewController class]]||[self.topViewController isKindOfClass:[ALChatViewController class]]) {
        //flag= True  ....continue as normal
        NSLog(@"TRUEEE");
    }
    else {
        //flag= False... Go to the DemoLauncher... FROM the Current View.
        NSLog(@"FALSEEE");
        self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:@"applozic-sample-app"];

            //User is already registered ..directly launch the chat...
        if([ALUserDefaultsHandler getDeviceKeyString]){
        //                NSString * title = our3.title? our3.title: @"< Back";
        [self.chatLauncher launchIndividualChat:@"nayauser" andViewControllerObject:self.topViewController andWithText:nil ];
        }
    
    }

}
- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
        
    } else if (rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
        
    } else {
        return rootViewController;
    }
}

@end
