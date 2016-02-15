//
//  ALNewContactsViewController.h
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALChannelService.h"
#import "ALMessageDBService.h"


@protocol ALContactDelegate <NSObject>

-(void)addChannelCreateMessage:(NSMutableArray*)messagesArray;

@end


@interface ALNewContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mTableViewTopConstraint;

@property (nonatomic,strong) NSArray* colors;

-(UIView *)setCustomBackButton:(NSString *)text;

@property (nonatomic,strong) NSNumber* forGroup;
@property (nonatomic,strong)UIBarButtonItem *done;
@property (nonatomic,strong)NSString* groupName;

@property(nonatomic,assign)id delegate;
@end
