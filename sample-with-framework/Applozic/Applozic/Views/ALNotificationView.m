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
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"
#import "ALChannelDBService.h"
@implementation ALNotificationView
    



-(instancetype)initWithContactId:(NSString*) contactId orGroupId:(NSNumber*) groupId withAlertMessage: (NSString *) alertMessage{
    self = [super init];
    self.text = alertMessage;
    self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"BlueNotify.png"]];
//    self.backgroundColor=[UIColor grayColor];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 0;
    self.userInteractionEnabled = YES;
    self.contactId = contactId;
    self.groupId = groupId;
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
    
    ALChannel *channel=[[ALChannel alloc] init];
    ALChannelDBService *groupDb= [[ALChannelDBService alloc] init];
    
    NSString* title;
    NSString *message = [NSString stringWithFormat:@"%@",self.text]; //20 characters fixed
    if([message isEqualToString:@""]){
        message=[NSString stringWithFormat:@"Attachment"];
    }
    
    if(self.groupId){
        
        channel = [groupDb loadChannelByKey:self.groupId];
        
        if(dpName.userId == nil){  // Avoids (null) to show up in Notificaition
                dpName.userId=@"";
        }
        if(channel.name == nil){
                channel.name=self.groupId;
        }
        
        title=channel.name;
        message = [NSString stringWithFormat:@"%@:%@",dpName.userId,message];
        _contactId=[NSString stringWithFormat:@"%@",self.groupId];
            
        }
    else {
        title=dpName.getDisplayName;
    }
    
    message = (message.length > 20) ? [NSString stringWithFormat:@"%@...",[message substringToIndex:17]] : message;
    
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
   
    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:17]];
    [[TSMessageView appearance] setContentFont:[UIFont systemFontOfSize:13]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];
    
    
    [TSMessage showNotificationInViewController:top.topViewController
                                          title:title
                                       subtitle:message
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:
     ^(void){
         
         if([delegate isKindOfClass:[ALMessagesViewController class]] && top.isMessageViewOnTop){
             // Conversation View is Opened.....
             ALMessagesViewController* class2=(ALMessagesViewController*)delegate;
             if(self.groupId){
                 class2.channelKey=self.groupId; NSLog(@"CLASS %@",class2.channelKey);
                 //_contactId=self.groupId; CRASH: if you send contactId as NSNumber.
             }
             else{
                 class2.channelKey=nil;
                 self.groupId=nil;
             }
             NSLog(@"onTopMessageVC: ContactID %@ and ChannelID %@",self.contactId, self.groupId);
             [class2 createDetailChatViewController:_contactId];
             self.checkContactId=[NSString stringWithFormat:@"%@",self.contactId];
             
         }
         else if([delegate isKindOfClass:[ALChatViewController class]] && top.isChatViewOnTop2){
             // Chat View is Opened....
             ALChatViewController * class1= (ALChatViewController*)delegate;
             NSLog(@"onTopChatVC: ContactID %@ and ChannelID %@",self.contactId, self.groupId);
             if(self.groupId){
                 class1.channelKey=self.groupId;
             }
             else {
                 class1.channelKey=nil;
                 self.groupId=nil;
             }
             class1.contactIds=self.contactId;
             [class1 reloadView];
             [class1 processMarkRead];
             [class1 fetchAndRefresh:YES];
             [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
         }
         else{
             NSLog(@"View Already Opened and Notification coming already");
         }
}
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
    
    
    
}
@end
