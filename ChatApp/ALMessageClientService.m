//
//  ALMessageClientService.m
//  ChatApp
//
//  Created by devashish on 02/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALMessageClientService.h"
#import "ALConstant.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALMessage.h"
#import "ALUserDefaultsHandler.h"

@implementation ALMessageClientService

-(void) updateDeliveryReports:(NSMutableArray *) messages
{
    for (ALMessage * theMessage in messages) {
        [self updateDeliveryReport:theMessage.pairedMessageKeyString userId:theMessage.contactIds];
    }
}

-(void) updateDeliveryReport: (NSString *) key userId: (NSString *) userId
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/sms/mtext/delivered",KBASE_URL];
    NSString *theParamString = [NSString stringWithFormat:@"smsKeyString=%@&userId=%@&contactNumber=%@", key, [ALUserDefaultsHandler getUserId], userId];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"DEILVERY_REPORT" WithCompletionHandler:^(id theJson, NSError *theError) {
        NSLog(@"server response received for delivery report %@", theJson);
        
        if (theError) {
            
            //completion(nil,theError);
            
            return ;
        }
        
        //completion(response,nil);
        
    }];

    
}


@end
