//
//  ALMessageClientService.h
//  ChatApp
//
//  Created by devashish on 02/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALMessageClientService : NSObject

-(void) updateDeliveryReports:(NSMutableArray *) messages;

-(void) updateDeliveryReport: (NSString *) key userId: (NSString *) userId;

@end
