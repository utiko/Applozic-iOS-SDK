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

    //<><<<<<><><><><><><><>>OUR VIEW is opned<><>><><><><><><><><><><><><><>><<>
    
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
    
    ALPushAssist* top=[[ALPushAssist alloc] init];

    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
   
    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:17]];
    [[TSMessageView appearance] setContentFont:[UIFont systemFontOfSize:13]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];
    
    [TSMessage showNotificationInViewController:top.topViewController
                                          title:@"APPLOZIC"
                                       subtitle:[NSString stringWithFormat:@"%@: %@",_contactId,self.text]
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:
     ^(void){
            if([delegate isKindOfClass:[ALChatViewController class]]){
                ALChatViewController * class1= (ALChatViewController*)delegate;
                class1.contactIds=self.contactId;
                [class1 reloadView];
                [class1 processMarkRead];
                [class1 fetchAndRefresh:YES];
                                               
            }
            else{ //[delegate isKindOfClass:[ALMessageViewController class]]
                ALMessagesViewController* class2=(ALMessagesViewController*)delegate;
                [class2 createDetailChatViewController:_contactId];
            }
        
    }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}
@end
