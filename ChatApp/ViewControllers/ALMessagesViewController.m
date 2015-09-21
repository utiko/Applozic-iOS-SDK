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
#import "ALUserDefaultsHandler.h"
#import "DB_SMS.h"
#import "ALDBHandler.h"
#import "ALContact.h"
#import "DB_CONTACT.h"
#import "DB_FileMetaInfo.h"

// Constants
#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64

//------------------------------------------------------------------------------------------------------------------
// Private interface
//------------------------------------------------------------------------------------------------------------------

@interface ALMessagesViewController ()

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

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setUpView];
    [self setUpTableView];

    if ([ALUserDefaultsHandler getBoolForKey_isConversationDbSynced] == NO) { // db is not synced

        [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray * theArray) {

            if (success) {
                // save data into the db
                ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
                for (ALMessage * theMessage in theArray) {
                    DB_SMS * theSmsEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_SMS" inManagedObjectContext:theDBHandler.managedObjectContext];
                    theSmsEntity.isSent = [NSNumber numberWithBool:theMessage.sent];
                    theSmsEntity.isSentToDevice = [NSNumber numberWithBool:theMessage.sendToDevice];
                    theSmsEntity.isStoredOnDevice = [NSNumber numberWithBool:NO];
                    theSmsEntity.isShared = [NSNumber numberWithBool:theMessage.shared];
                    theSmsEntity.isRead = [NSNumber numberWithBool:theMessage.read];
                    theSmsEntity.keyString = theMessage.keyString;
                    theSmsEntity.deviceKeyString = theMessage.deviceKeyString;
                    theSmsEntity.suUserKeyString = theMessage.suUserKeyString;
                    theSmsEntity.to = theMessage.to;
                    theSmsEntity.messageText = theMessage.message;
                    theSmsEntity.createdAt = [NSNumber numberWithInteger:theMessage.createdAtTime.integerValue];
                    theSmsEntity.type = theMessage.type;
                    theSmsEntity.contactId = theMessage.contactIds;
                    theSmsEntity.filePath = theMessage.imageFilePath;

                    if (theMessage.fileMetas != nil) {
                        DB_FileMetaInfo * theMetaInfoEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_FileMetaInfo" inManagedObjectContext:theDBHandler.managedObjectContext];
                        theMetaInfoEntity.blobKeyString = theMessage.fileMetas.blobKeyString;
                        theMetaInfoEntity.contentType = theMessage.fileMetas.contentType;
                        theMetaInfoEntity.createdAtTime = theMessage.fileMetas.createdAtTime;
                        theMetaInfoEntity.keyString = theMessage.fileMetas.keyString;
                        theMetaInfoEntity.name = theMessage.fileMetas.name;
                        theMetaInfoEntity.size = theMessage.fileMetas.size;
                        theMetaInfoEntity.suUserKeyString = theMessage.fileMetas.suUserKeyString;
                        theMetaInfoEntity.thumbnailUrl = theMessage.fileMetas.thumbnailUrl;
                        theSmsEntity.fileMetaInfo = theMetaInfoEntity;
                    }
                }

                [theDBHandler.managedObjectContext save:nil];
                // set yes to userdefaults
                [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
                // add default contacts
                [self syncConactsDB];
                //fetch data from db
                [self fetchConversationsGroupByContactId];
            }
        }];
    }
    else // db is synced
    {
        //fetch data from db
        [self fetchConversationsGroupByContactId];
    }
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

    ALChatViewController * theVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    theVC.mLatestMessage =  self.mContactsMessageListArray[indexPath.row];
    [self.navigationController pushViewController:theVC animated:YES];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark -  Helper methods
//------------------------------------------------------------------------------------------------------------------

-(void) syncConverstionDBWithCompletion:(void(^)(BOOL success , NSMutableArray * theArray)) completion
{
    [self.mActivityIndicator startAnimating];
    [ALMessageService getMessagesListGroupByContactswithCompletion:^(NSMutableArray *messageArray, NSError *error) {
        [self.mActivityIndicator stopAnimating];
        if (error) {
            NSLog(@"%@",error);
            completion(NO,nil);
            return ;
        }
        NSMutableArray * dataArray = [NSMutableArray arrayWithArray:messageArray];
        completion(YES,dataArray);
    }];
}

-(void) syncConactsDB
{
    // adding default data
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];

    // contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"111";
    contact1.fullName = @"Gaurav Nigam";
    contact1.contactNumber = @"1234561234";
    contact1.displayName = @"Gaurav";
    contact1.email = @"123@abc.com";
    contact1.contactImageUrl = nil;

    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"222";
    contact2.fullName = @"Navneet Nav";
    contact2.contactNumber = @"987651234";
    contact2.displayName = @"Navneet";
    contact2.email = @"456@abc.com";
    contact2.contactImageUrl = nil;

    // contact 3
    ALContact *contact3 = [[ALContact alloc] init];
    contact3.userId = @"applozic";
    contact3.fullName = @"applozic";
    contact3.contactNumber = @"678906543";
    contact3.displayName = @"Priyesh";
    contact3.email = @"789@abc.com";
    contact3.contactImageUrl = nil;

    [theDBHandler addListOfContacts:@[contact1,contact2,contact3]];
}

-(void) fetchConversationsGroupByContactId
{
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    // get all unique contacts

    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
    [theRequest setResultType:NSDictionaryResultType];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [theRequest setPropertiesToFetch:@[@"contactId"]];
    [theRequest setReturnsDistinctResults:YES];

    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    // get latest record
    for (NSDictionary * theDictionary in theArray) {
        NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
        [theRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId = %@",theDictionary[@"contactId"]]];
        [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [theRequest setFetchLimit:1];

        NSArray * theArray =  [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
        DB_SMS * theSmsEntity = theArray.firstObject;
        ALMessage * theMessage = [ALMessage new];
        theMessage.to = theSmsEntity.to;
        theMessage.message = theSmsEntity.messageText;
        theMessage.contactIds = theSmsEntity.contactId;
        theMessage.type = theSmsEntity.type;
        theMessage.createdAtTime = [NSString stringWithFormat:@"%@",theSmsEntity.createdAt];
        [self.mContactsMessageListArray addObject:theMessage];
    }
    [self.mTableView reloadData];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Notification observers
//------------------------------------------------------------------------------------------------------------------

-(void) updateConversationTableNotification:(NSNotification *) notification
{
    ALMessage * theMessage = notification.object;
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


@end
