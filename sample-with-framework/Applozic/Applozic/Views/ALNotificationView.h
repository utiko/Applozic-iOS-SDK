//
//  ALNotificationView.h
//  ChatApp
//
//  Created by Devashish on 06/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALNotificationView : UILabel


@property (retain ,nonatomic) NSString * contactId;

-(instancetype)initWithContactId:(NSString*) contactId withAlertMessage: (NSString *) alertMessage;

-(void)displayNotification:(id)delegate;
@end
