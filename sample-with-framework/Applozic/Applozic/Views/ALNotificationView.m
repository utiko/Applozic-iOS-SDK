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
    



-(instancetype)initWithAlMessage:(ALMessage*)alMessage  withAlertMessage: (NSString *) alertMessage{
    self = [super init];
    self.text = alertMessage;
    self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"BlueNotify.png"]];
//    self.backgroundColor=[UIColor grayColor];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 0;
    self.userInteractionEnabled = YES;
    self.contactId = alMessage.contactIds;
    self.groupId = alMessage.groupId;
    self.conversationId = alMessage.conversationId;
    return self;
}


- (void)customizeMessageView:(TSMessageView *)messageView
{
    messageView.alpha = 0.4;
    messageView.backgroundColor=[UIColor blackColor];
}

-(void)nativeNotification:(id)delegate{
    
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
    
    if(!self.groupId || [self.groupId intValue]==0){
        title=dpName.getDisplayName;
    }else {
        channel = [groupDb loadChannelByKey:self.groupId];
        if(dpName.userId == nil){  // Avoids (null) to show up in Notificaition
            dpName.userId=@"";
        }
        if(channel.name == nil){
            channel.name=self.groupId;
        }
        
        title=channel.name;
        
        NSArray *notificationComponents = [dpName.getDisplayName componentsSeparatedByString:@":"];
        if(notificationComponents.count>1){
            dpName.userId = [notificationComponents lastObject];
        }
        else{
            dpName.userId = dpName.getDisplayName;
        }
        
        message = [NSString stringWithFormat:@"%@:%@",dpName.userId,message];
        _contactId=[NSString stringWithFormat:@"%@",self.groupId];
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
             
             if (self.conversationId) {
                 class1.conversationId = self.conversationId;
                 [[class1.alMessageWrapper messageArray] removeAllObjects];
                 [class1 processLoadEarlierMessages:YES];
             }
             else{
                 class1.conversationId = nil;
                 class1.contactIds=self.contactId;
                 [class1 reloadView];
                 [class1 processMarkRead];
                 [class1 fetchAndRefresh:YES];
                 [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
             }
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

-(void)showGroupLeftMessage{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle:@"You have left this group" type:TSMessageNotificationTypeWarning];
}
@end
