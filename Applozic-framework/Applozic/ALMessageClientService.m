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
#import "ALMessageDBService.h"
#import "ALDBHandler.h"

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

-(void) addWelcomeMessage
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    
    ALMessage * theMessage = [ALMessage new];
    
    theMessage.type = @"4";
    theMessage.contactIds = @"applozic";//1
    theMessage.to = @"applozic";//2
    theMessage.createdAtTime = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]*1000];
    theMessage.deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString ];
    theMessage.message = @"Welcome to Applozic! Drop a message here or contact us at devashish@applozic.com for any queries. Thanks";//3
    theMessage.sendToDevice = NO;
    theMessage.sent = NO;
    theMessage.shared = NO;
    theMessage.fileMetas = nil;
    theMessage.read = NO;
    theMessage.keyString = @"welcome-message-temp-key-string";
    theMessage.delivered=NO;
    theMessage.fileMetaKeyStrings = @[];//4
    
    [messageDBService createSMSEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];

}


@end
