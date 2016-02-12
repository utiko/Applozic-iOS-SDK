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

@property (retain ,nonatomic) NSString * checkContactId;

@property (retain, nonatomic) NSNumber * groupId;

-(instancetype)initWithContactId:(NSString*) contactId orGroupId:(NSNumber*) groupId withAlertMessage: (NSString *) alertMessage;

-(void)displayNotification:(id)delegate;
-(void)displayNotificationNew:(id)delegate;
@end
