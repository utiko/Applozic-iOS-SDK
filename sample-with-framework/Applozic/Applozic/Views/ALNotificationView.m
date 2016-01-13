//
//  ALNotificationView.m
//  ChatApp
//
//  Created by Devashish on 06/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALNotificationView.h"

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

@end
