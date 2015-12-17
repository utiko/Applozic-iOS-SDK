//
//  ALDateCell.h
//  Applozic
//
//  Created by devashish on 16/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALDateCell : UIViewController

@property (strong, nonatomic) NSString *dateCellText;

-(BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer;

@end
