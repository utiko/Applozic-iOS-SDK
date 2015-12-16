//
//  ALSyncCallService.h
//  Applozic
//
//  Created by Applozic Inc on 12/14/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALUserDetail.h"

@interface ALSyncCallService : NSObject

-(void) updateMessageDeliveryReport: (NSString *) messageKey;

-(void) updateDeliveryStatusForContact: (NSString *) contactId;

-(void) syncCall: (ALMessage *) alMessage;

-(void) updateConnectedStatus: (ALUserDetail *) alUserDetail;

@end
