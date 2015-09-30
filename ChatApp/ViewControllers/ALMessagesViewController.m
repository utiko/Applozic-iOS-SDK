//
//  ViewController.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessagesViewController.h"
#import "ALConstant.h"
#import "ALContactCell.h"
#import "ALMessageService.h"
#import "ALMessage.h"
#import "ALChatViewController.h"
#import "ALUtilityClass.h"
#import "ALContact.h"
#import "ALMessageDBService.h"
#import "ALLoginViewController.h"
#import "ALRegisterUserClientService.h"
// Constants
#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64



//------------------------------------------------------------------------------------------------------------------
// Private interface
//------------------------------------------------------------------------------------------------------------------

@interface ALMessagesViewController ()<UITableViewDataSource,UITableViewDelegate,ALMessagesDelegate>

- (IBAction)logout:(id)sender;

// Constants

// IBOutlet
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

// Private Varibles
@property (nonatomic, strong) NSMutableArray * mContactsMessageListArray;
@property (nonatomic, strong) UIColor *navColor;

@end

@implementation ALMessagesViewController

//------------------------------------------------------------------------------------------------------------------
    #pragma mark - View lifecycle
//------------------------------------------------------------------------------------------------------------------


- (IBAction)logout:(id)sender {

    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService logout];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    ALLoginViewController *add =
    [storyboard instantiateViewControllerWithIdentifier:@"ALLoginViewController"];
    
    [self presentViewController:add
                       animated:YES
                     completion:nil];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setUpView];
    [self setUpTableView];
    self.mTableView.allowsMultipleSelectionDuringEditing = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeliveryReport:) name:@"deliveryReport" object:nil];
    
    ALMessageDBService *dBService = [ALMessageDBService new];
    dBService.delegate = self;
    [dBService getMessages];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    }
}

-(void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    self.navigationController.navigationBar.barTintColor = self.navColor;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

-(void)setUpView {
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    if (!color) {
        color = [UIColor blackColor];
    }
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationItem.title = @"Conversation";

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        self.navColor = [self.navigationController.navigationBar tintColor];
    else
        self.navColor = [self.navigationController.navigationBar barTintColor];
}

-(void)setUpTableView {
    self.mContactsMessageListArray = [NSMutableArray new];
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationTableNotification:) name:@"updateConversationTableNotification" object:nil];
}

//------------------------------------------------------------------------------------------------------------------
    #pragma mark - ALMessagesDelegate
//------------------------------------------------------------------------------------------------------------------

-(void)getMessagesArray:(NSMutableArray *)messagesArray {
    self.mContactsMessageListArray = messagesArray;
    [self.mTableView reloadData];
}


//------------------------------------------------------------------------------------------------------------------
    #pragma mark - Table View DataSource Methods
//------------------------------------------------------------------------------------------------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return (self.mTableView==nil)?0:1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.mContactsMessageListArray.count>0?[self.mContactsMessageListArray count]:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"ContactCell";
    ALContactCell *contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ALMessage *message = (ALMessage *)self.mContactsMessageListArray[indexPath.row];
    contactCell.mUserImageView.image = [UIImage imageNamed:@"ic_mobicom.png"];
    contactCell.mUserNameLabel.text = message.to;
    contactCell.mMessageLabel.text = message.message;
    if ([message.type integerValue] == [FORWARD_STATUS integerValue])
        contactCell.mLastMessageStatusImageView.image = [UIImage imageNamed:@"mobicom_social_forward.png"];
    else if ([message.type integerValue] == [REPLIED_STATUS integerValue])
        contactCell.mLastMessageStatusImageView.image = [UIImage imageNamed:@"mobicom_social_reply.png"];

    BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
    contactCell.mTimeLabel.text = [message getCreatedAtTime:isToday];

    return contactCell;
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Delegate Methods
//------------------------------------------------------------------------------------------------------------------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALMessage * message=  self.mContactsMessageListArray[indexPath.row];
    
    if (!(self.detailChatViewController))
    {
        _detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    _detailChatViewController.contactIds = message.contactIds;
    [self.navigationController pushViewController:_detailChatViewController animated:YES];
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Editing Methods
//------------------------------------------------------------------------------------------------------------------

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
       
        NSLog(@"Delete Pressed");
        
        
    }
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Notification observers
//------------------------------------------------------------------------------------------------------------------

-(void) updateConversationTableNotification:(NSNotification *) notification
{
    ALMessage * theMessage = notification.object;
    NSLog(@"notification for table update...%@", theMessage.message);
    NSArray * theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIds = %@",theMessage.contactIds]];

    ALMessage * theLatestMessage = theFilteredArray.firstObject;
    if ([theMessage.createdAtTime isEqualToString:theLatestMessage.createdAtTime] == NO) {
        [self.mContactsMessageListArray removeObject:theLatestMessage];
        [self.mContactsMessageListArray insertObject:theMessage atIndex:0];
        [self.mTableView reloadData];
    }
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - View orientation methods
//------------------------------------------------------------------------------------------------------------------

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    UIInterfaceOrientation toOrientation   = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone && (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)) {
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_LANDSCAPE_CONSTANT;
    }else{
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_PORTRAIT_CONSTANT;
    }

    [self.view layoutIfNeeded];
}


-(void)pushNotificationhandler:(NSNotification *) notification{
  
    // see if this view is visible or not...
    NSString * contactId = notification.object;
    NSLog(@"yes comes here %@", contactId);

    if (self.isViewLoaded && self.view.window) {
                //Show notification...
        NSLog(@"current quick view is visible");
        ALMessageDBService *dBService = [ALMessageDBService new];
        dBService.delegate = self;
        [dBService fetchAndRefreshFromServer];
        return;
    }
    
    if (!(self.detailChatViewController)){
        _detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
        _detailChatViewController.contactIds =contactId;
        [self.navigationController pushViewController:_detailChatViewController animated:YES];
    }
    else if ([self.detailChatViewController.contactIds isEqualToString:contactId ]){
            //update same view- working fine
         [self.detailChatViewController fetchAndRefresh];
    }else {
        //show notification .on the top (local notification)
       
    }
  
}

-(void)updateDeliveryReport:(NSNotification *) notification {
    
    NSString * keyString = notification.object;
    if (self.isViewLoaded && self.view.window) {
        NSArray * filteredArray = [self.mContactsMessageListArray  filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keyString == %@",keyString]];
        if (filteredArray.count > 0) {
           ALMessage * alMessage =  filteredArray[0];
            alMessage.delivered =YES;
            [self.mTableView reloadData];
        }
    }else if ((self.detailChatViewController)){
        [self.detailChatViewController updateDeliveryReport:keyString];
    }
    
}
@end
