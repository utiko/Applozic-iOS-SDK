//
//  ALSyncCallService.m
//  Applozic
//
//  Created by Applozic Inc on 12/14/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALSyncCallService.h"
#import "ALMessageDBService.h"
#import "ALContactDBService.h"

@implementation ALSyncCallService


-(void) updateMessageDeliveryReport:(NSString *)messageKey {
    ALMessageDBService *alMessageDBService = [[ALMessageDBService init] alloc];
    [alMessageDBService updateMessageDeliveryReport:messageKey];
    NSLog(@"delivery report for %@", messageKey);
    //Todo: update ui
}

-(void) updateDeliveryStatusForContact:(NSString *)contactId {
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
    [messageDBService updateDeliveryReportForContact:contactId];
    //Todo: update ui
}

-(void) syncCall: (ALMessage *) alMessage {
    
}

-(void) updateConnectedStatus: (ALUserDetail *) alUserDetail {
    ALContactDBService* contactDBService = [[ALContactDBService alloc] init];
    [contactDBService updateUserDetail: alUserDetail];
}

@end
