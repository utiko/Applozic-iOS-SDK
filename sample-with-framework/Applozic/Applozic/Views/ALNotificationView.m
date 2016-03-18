//
//  ALNotificationView.m
//  ChatApp
//
//  Created by Devashish on 06/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALNotificationView.h"
#import "TSMessage.h"
#import "ALPushAssist.h"
#import "ALUtilityClass.h"
#import "ALChatViewController.h"
#import "TSMessageView.h"
#import "ALMessagesViewController.h"
#import "ALUserDefaultsHandler.h"
#import "ALApplozicSettings.h"
#import "ALContactDBService.h"
@implementation ALNotificationView




-(instancetype)initWithContactId:(NSString*) contactId withAlertMessage: (NSString *) alertMessage{
    self = [super init];
    self.text = alertMessage;
    self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"BlueNotify.png"]];
    //    self.backgroundColor=[UIColor grayColor];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 0;
    self.userInteractionEnabled = YES;
    self.contactId = contactId;
    return self;
}


-(void)displayNotification:(id)delegate
{
    //    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    
    
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(handleNotification:)];
    [self addGestureRecognizer:tapGesture];
    
    
    
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow bringSubviewToFront:self];
    self.frame = CGRectMake(0.0, -75.00, keyWindow.frame.size.width, 75.00);
    [keyWindow addSubview:self];
    //Action Event
    
    [UIView animateWithDuration:0.5 animations:^{
        // set new position of label which it will animate to
        self.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width, 75.00);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(0.0, -75.00, keyWindow.frame.size.width, 75.00);
        }];
        //            [self removeFromSuperview];
        
    });
    
}
- (void)customizeMessageView:(TSMessageView *)messageView
{
    messageView.alpha = 0.4;
    messageView.backgroundColor=[UIColor blackColor];
}

-(void)displayNotificationNew:(id)delegate{
  
    //<><><><><><><><><><><><><><><><><><><><><><>OUR VIEW is opned<><>><><><><><><><><><><><><><><><>//
    
    ALPushAssist* top=[[ALPushAssist alloc] init];

    ALContact* dpName=[[ALContact alloc] init];
    ALContactDBService * contactDb=[[ALContactDBService alloc] init];
    dpName=[contactDb loadContactByKey:@"userId" value:self.contactId];
    
    NSString *message = [NSString stringWithFormat:@"%@",self.text]; //20 characters fixed
    
    if([message isEqualToString:@""]){
        message=[NSString stringWithFormat:@"Attachment"];
    }

    message = [NSString stringWithFormat:@"%@:%@",dpName.displayName,message];
    message = (message.length > 20) ? [NSString stringWithFormat:@"%@...",[message substringToIndex:17]] : message;
    
   
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
   

    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:17]];
    [[TSMessageView appearance] setContentFont:[UIFont systemFontOfSize:13]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:[ALApplozicSettings getFontFace]  size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];
    
    NSString *myString = [NSString stringWithFormat:@"%@",self.text];
    myString = (myString.length > 20) ? [NSString stringWithFormat:@"%@...",[myString substringToIndex:20]] : myString;
    

    if([myString isEqualToString:@""]){
        myString=[NSString stringWithFormat:@"Attachment"];
    }
    [TSMessage showNotificationInViewController:top.topViewController
                                          title:[ALUserDefaultsHandler getNotificationTitle]
                                       subtitle:message
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:
     ^(void){
         
         if([delegate isKindOfClass:[ALMessagesViewController class]] && top.isMessageViewOnTop){
             // Conversation View is Opened.....
             ALMessagesViewController* class2=(ALMessagesViewController*)delegate;
             [class2 createDetailChatViewController:_contactId];
             self.checkContactId=[NSString stringWithFormat:@"%@",self.contactId];
             
         }
         else if([delegate isKindOfClass:[ALChatViewController class]] && top.isChatViewOnTop2){
             // Chat View is Opened....
             ALChatViewController * class1= (ALChatViewController*)delegate;
             class1.contactIds=self.contactId;
             [class1 reloadView];
             [class1 processMarkRead];
             [class1 fetchAndRefresh:YES];
             [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
         }
         else{
             NSLog(@"View Already Opened and Notification coming already");
         }
         
         [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
         [[UIApplication sharedApplication] cancelAllLocalNotifications];
         
     }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
    
    
    
}


-(void)setupNotificaitionTitle{
    //<><><><><><><><><><><><><><><><><><><><><><>OUR VIEW is opned<><>><><><><><><><><><><><><><><><>//
    
    ALContact* dpName=[[ALContact alloc] init];
    ALContactDBService * contactDb=[[ALContactDBService alloc] init];
    dpName=[contactDb loadContactByKey:@"userId" value:self.contactId];
    NSString* title;
    NSString *message = [NSString stringWithFormat:@"%@",self.text]; //20 characters fixed
    
    if([message isEqualToString:@""]){
        message=[NSString stringWithFormat:@"Attachment"];
    }
    if(dpName.userId == nil){  // Avoids (null) to show up in Notificaition
            dpName.userId=@"";
    }
    NSArray *notificationComponents = [dpName.getDisplayName componentsSeparatedByString:@":"];
    if(notificationComponents.count>1){
        dpName.userId = [notificationComponents lastObject];
    }
    else{
        dpName.userId = dpName.getDisplayName;
    }
    message = [NSString stringWithFormat:@"%@:%@",dpName.userId,message];
    message = (message.length > 20) ? [NSString stringWithFormat:@"%@...",[message substringToIndex:17]] : message;
    

}
@end
