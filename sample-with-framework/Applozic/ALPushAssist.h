//
//  ALPushAssist.h
//  Applozic
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChatLauncher.h"


@interface ALPushAssist : NSObject

@property(nonatomic, readonly, strong) UIViewController *topViewController;

@property(nonatomic,strong) ALChatLauncher * chatLauncher;
-(void)assist;
-(void)notificaitionShow;
-(void)contextP:(NSNotification *)notif;
@end
