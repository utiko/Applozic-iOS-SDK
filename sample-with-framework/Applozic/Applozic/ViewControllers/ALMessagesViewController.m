//
//  ViewController.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#define NAVIGATION_TEXT_SIZE 20
#define USER_NAME_LABEL_SIZE 18
#define MESSAGE_LABEL_SIZE 12
#define TIME_LABEL_SIZE 10
#define IMAGE_NAME_LABEL_SIZE 14

#import "ALMessagesViewController.h"
#import "ALConstant.h"
#import "ALMessageService.h"
#import "ALMessage.h"
#import "ALChatViewController.h"
#import "ALUtilityClass.h"
#import "ALContact.h"
#import "ALMessageDBService.h"
#import "ALRegisterUserClientService.h"
#import "ALDBHandler.h"
#import "ALContact.h"
#import "ALUserDefaultsHandler.h"
#import "ALContactDBService.h"
#import "UIImageView+WebCache.h"
#import "ALLoginViewController.h"
#import "ALColorUtility.h"
#import "ALMQTTConversationService.h"
#import "ALApplozicSettings.h"
#import "ALDataNetworkConnection.h"
#import "ALUserService.h"
#import "ALChannelDBService.h"
#import "ALChannel.h"
#import "ALChatLauncher.h"
#import "ALChannelService.h"


// Constants
#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64
#define MQTT_MAX_RETRY 3



//------------------------------------------------------------------------------------------------------------------
// Private interface
//------------------------------------------------------------------------------------------------------------------

@interface ALMessagesViewController ()<UITableViewDataSource,UITableViewDelegate,ALMessagesDelegate, ALMQTTConversationDelegate>

- (IBAction)logout:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
- (IBAction)backButtonAction:(id)sender;
-(void)emptyConversationAlertLabel;
// Constants

// IBOutlet
//@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

// Private Variables
@property (nonatomic) NSInteger mqttRetryCount;
@property (nonatomic, strong) NSMutableArray * mContactsMessageListArray;
@property (nonatomic, strong) UIColor *navColor;
@property (nonatomic,strong) NSArray *unreadCount;
@property (nonatomic,strong) NSArray* colors;
@property (strong, nonatomic) UILabel *emptyConversationText;
@property (strong, nonatomic) UILabel *dataAvailablityLabel;
@property (strong, nonatomic) NSNumber *channelKey;
@property(strong, nonatomic) ALMQTTConversationService *alMqttConversationService;
@end

// $$$$$$$$$$$$$$$$$$ Class Extension for solving Constraints Issues.$$$$$$$$$$$$$$$$$$$$
@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

@implementation ALMessagesViewController




//------------------------------------------------------------------------------------------------------------------
#pragma mark - View lifecycle
//------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _mqttRetryCount = 0;
    
    [self setUpView];
    [self setUpTableView];
    self.mTableView.allowsMultipleSelectionDuringEditing = NO;
    [self.mActivityIndicator startAnimating];
    
    ALMessageDBService *dBService = [ALMessageDBService new];
    dBService.delegate = self;
    [dBService getMessages];
    
    self.unreadCount = [[NSArray alloc] init];
    _alMqttConversationService = [ALMQTTConversationService sharedInstance];
    _alMqttConversationService.mqttConversationDelegate = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [_alMqttConversationService subscribeToConversation];
    });
    
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 15 + self.view.frame.size.width/8, self.view.frame.origin.y + self.view.frame.size.height/2, 250, 30)];
    [self.emptyConversationText setText:@"You have no conversations yet"];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.emptyConversationText];
    
    self.dataAvailablityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 30)];
    [self.dataAvailablityLabel setText:@"NO INTERNET CONNECTION"];
    [self.dataAvailablityLabel setBackgroundColor:[UIColor colorWithRed:179.0/255 green:32.0/255 blue:35.0/255 alpha:1]];
    [self.dataAvailablityLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dataAvailablityLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.dataAvailablityLabel];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton:@"Back"]];
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"Unsubscribing mqtt from ALMessageVC");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alMqttConversationService unsubscribeToConversation];
        });
}

-(void)dropShadowInNavigationBar
{
    //  self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationController.navigationBar.layer.shadowRadius = 10;
    self.navigationController.navigationBar.layer.masksToBounds = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self dropShadowInNavigationBar];
//    [[self.navigationItem leftBarButtonItem] setTitle:[ALApplozicSettings getBackButtonTitle]];
    
    if([ALUserDefaultsHandler isLogoutButtonHidden])
    {
        [self.navBar setRightBarButtonItems:nil];
    }
    if([ALUserDefaultsHandler isBackButtonHidden])
    {
        [self.navBar setLeftBarButtonItems:nil];
    }
    
    self.detailChatViewController.contactIds = nil;
    
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    }
    
    //register for notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationhandler:) name:@"pushNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callLastSeenStatusUpdate)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
   // [[NSNotificationCenter defaultCenter]  removeObserver:self name:@"showNotificationAndLaunchChat" object:nil];
    
    if ([_detailChatViewController refreshMainView])
    {
        ALMessageDBService *dBService = [ALMessageDBService new];
        dBService.delegate = self;
        [dBService getMessages];
        [_detailChatViewController setRefreshMainView:FALSE];
    }
    
    //     [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
    
    if([ALApplozicSettings getColourForNavigation] && [ALApplozicSettings getColourForNavigationItem])
    {
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColourForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColourForNavigationItem]];
    }
    
    [self.mTableView reloadData];
    
    if([self.mActivityIndicator isAnimating])
    {
        [self.emptyConversationText setHidden:YES];
    }
    else
    {
        [self emptyConversationAlertLabel];
    }
    
    [self.dataAvailablityLabel setHidden:YES];
    [self callLastSeenStatusUpdate];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if (![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [self.dataAvailablityLabel setHidden:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.dataAvailablityLabel setHidden:YES];
        });
    }
    else
    {
        [self.dataAvailablityLabel setHidden:YES];
    }
    
}

-(void)emptyConversationAlertLabel
{
    if(self.mContactsMessageListArray.count == 0)
    {
        [self.emptyConversationText setHidden:NO];
    }
    else
    {
        [self.emptyConversationText setHidden:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    //unregister for notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
    // self.navigationController.navigationBar.barTintColor = self.navColor;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_alMqttConversationService unsubscribeToConversation];
//    });
}

- (IBAction)logout:(id)sender {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController *contcatListView = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    [self.navigationController pushViewController:contcatListView animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

-(void)setUpView {
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    if (!color) {
        color = [UIColor blackColor];
        //        color = [UIColor whiteColor];
    }
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    //    self.navigationItem.title = @"Conversation";
    self.navigationItem.title = [ALApplozicSettings getTitleForConversationScreen];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        self.navColor = [self.navigationController.navigationBar tintColor];
    } else {
        self.navColor = [self.navigationController.navigationBar barTintColor];
    }
    self.colors = [[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
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
    [self.mActivityIndicator stopAnimating];
    
    if(messagesArray.count == 0)
    {
        [[self emptyConversationText] setHidden:NO];
    }
    else
    {
        [[self emptyConversationText] setHidden:YES];
    }
    
    self.mContactsMessageListArray = messagesArray;
    [self.mTableView reloadData];
}

-(void)updateMessageList:(NSMutableArray *)messagesArray {
    
    BOOL isreloadRequire = false;
    for ( ALMessage *msg  in  messagesArray){
        ALContactCell *contactCell = [self getCell:msg.contactIds];
        if(contactCell){
            NSLog(@"contact cell found ....");
            contactCell.mMessageLabel.text = msg.message;
            
            ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
            ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: msg.contactIds];
            
            if(alContact.connected)
            {
                [contactCell.onlineImageMarker setHidden:NO];
            }
            else
            {
                [contactCell.onlineImageMarker setHidden:YES];
            }
            
            UILabel* unread=(UILabel*)[contactCell viewWithTag:104];
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
            unread.hidden=FALSE;
            contactCell.mCountImageView.hidden=FALSE;
            unread.text=[NSString stringWithFormat:@"%lu",(unsigned long)[[messageDBService getUnreadMessages:msg.contactIds] count]];
            if ([msg.type integerValue] == [FORWARD_STATUS integerValue])
                contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_forward.png"];
            else if ([msg.type integerValue] == [REPLIED_STATUS integerValue])
                contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_reply.png"];
            
            BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[msg.createdAtTime doubleValue]/1000]];
            contactCell.mTimeLabel.text = [msg getCreatedAtTime:isToday];
            
        }else{
            isreloadRequire = true;
            [self.mContactsMessageListArray insertObject:msg atIndex:0];
            
            NSLog(@"contact cell not found ....");
        }
    }
    if(isreloadRequire){
        [self.mTableView reloadData];
    }
    
    
}

-(ALContactCell * ) getCell:(NSString *)key{
    
    int index=(int) [self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop)
                     {
                         ALMessage *message = (ALMessage*)element;
                         if( [ message.contactIds isEqualToString:key ])
                         {
                             *stop = YES;
                             return YES;
                         }
                         return NO;
                     }];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    ALContactCell *contactCell  = (ALContactCell *)[self.mTableView cellForRowAtIndexPath:path];
    return contactCell;
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View DataSource Methods
//------------------------------------------------------------------------------------------------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (self.mTableView == nil)?0:1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.mContactsMessageListArray.count>0?[self.mContactsMessageListArray count]:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ContactCell";
    ALContactCell *contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [contactCell.mUserNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:USER_NAME_LABEL_SIZE]];//size check
    [contactCell.mMessageLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_LABEL_SIZE]];
    [contactCell.mTimeLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:TIME_LABEL_SIZE]];
    [contactCell.imageNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:IMAGE_NAME_LABEL_SIZE]];
    
    ALMessage *message = (ALMessage *)self.mContactsMessageListArray[indexPath.row];
    
    UILabel* nameIcon=(UILabel*)[contactCell viewWithTag:102];
    nameIcon.textColor=[UIColor whiteColor];
    UILabel* unread=(UILabel*)[contactCell viewWithTag:104];
    
    [contactCell.onlineImageMarker setBackgroundColor:[UIColor clearColor]];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: message.to];
    if([message.groupId intValue])
    {
        //            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
        //            ALChannel *alChannel = [channelDBService loadChannelByKey:message.groupId];
        //                if(alChannel)
        //                {
        //                    NSArray *listNames = [[alChannel name] componentsSeparatedByString:@":"];
        //                    contactCell.mUserNameLabel.text = listNames[0];
        //                }
        
        ALChannelService *channelService = [[ALChannelService alloc] init];
        [channelService getChannelInformation:message.groupId withCompletion:^(ALChannel *alChannel) {
            NSArray *listNames = [[alChannel name] componentsSeparatedByString:@":"];
            contactCell.mUserNameLabel.text = listNames[0];
        }];
        
        
    }
    else
    {
        contactCell.mUserNameLabel.text = [alContact displayName];
        
    }
    
    contactCell.mMessageLabel.text = message.message;
    contactCell.mMessageLabel.hidden = NO;
    
    if ([message.type integerValue] == [FORWARD_STATUS integerValue])
        contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_forward.png"];
    else if ([message.type integerValue] == [REPLIED_STATUS integerValue])
        contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_reply.png"];
    
    BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
    contactCell.mTimeLabel.text = [message getCreatedAtTime:isToday];
    
    [self displayAttachmentMediaType:message andContactCell: contactCell];
    
    // here for msg dashboard profile pic
    
    NSString *firstLetter = [[[alContact displayName] substringToIndex:1] uppercaseString];
    nameIcon.text = firstLetter;
//    NSRange whiteSpaceRange = [[alContact displayName] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (whiteSpaceRange.location != NSNotFound)
//    {
//        NSArray *listNames = [[alContact displayName] componentsSeparatedByString:@" "];
//        NSString *firstLetter = [[listNames[0] substringToIndex:1] uppercaseString];
//        NSString *lastLetter = [[listNames[1] substringToIndex:1] uppercaseString];
//        nameIcon.text = [firstLetter stringByAppendingString:lastLetter];
//    }
//    else
//    {
//        nameIcon.text = firstLetter;
//    }
    
    
    if([message.groupId intValue])
    {
        [contactCell.onlineImageMarker setHidden:YES];
    }
    else if(alContact.connected)
    {
        [contactCell.onlineImageMarker setHidden:NO];
    }
    else
    {
        [contactCell.onlineImageMarker setHidden:YES];
    }
    
    ///////////$$$$$$$$$$$$$$$$//////////////////////COUNT//////////////////////$$$$$$$$$$$$$$$$///////////
    
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    self.unreadCount=[messageDBService getUnreadMessages:[alContact userId]];
    
    // NSLog(@"self.unreadCount Array of ||%@|| withCount ||%lu|| is %@",[alContact userId],(unsigned long)self.unreadCount.count,self.unreadCount);
    
    if(self.unreadCount.count!=0){
        unread.hidden=FALSE;
        contactCell.mCountImageView.hidden = NO;
        unread.text=[NSString stringWithFormat:@"%lu",(unsigned long)self.unreadCount.count];
    }
    else{
        unread.hidden=TRUE;
        contactCell.mCountImageView.hidden = YES;
    }
    
    
    
    contactCell.mUserImageView.hidden = NO;
    contactCell.mUserImageView.layer.cornerRadius = contactCell.mUserImageView.frame.size.width/2;
    contactCell.mUserImageView.layer.masksToBounds = YES;
    contactCell.mCountImageView.layer.cornerRadius = contactCell.mCountImageView.frame.size.width/2;

    ///////////$$$$$$$$$$$$$$$$//////////////////////COLORING//////////////////////$$$$$$$$$$$$$$$$///////////
    
    ///////////$$$$$$$$$$$$$$$$//////////////////////COLORING//////////////////////$$$$$$$$$$$$$$$$///////////
    
    NSUInteger randomIndex = random()% [self.colors count];
    contactCell.mUserImageView.image= [ALColorUtility imageWithSize:CGRectMake(0,0,55,55)
                                                      WithHexString:self.colors[randomIndex] ];
    
    
    ///////////$$$$$$$$$$$$$$$$//////////////////////$$$$$$$$$$$$$$$$//////////////////////$$$$$$$$$$$$$$$$///////////
    
    //applozic_group_icon
    if([message.groupId intValue])
    {
        [contactCell.mUserImageView setImage:[UIImage imageNamed:@"applozic_group_icon.png"]];
        nameIcon.hidden = YES;
    }
    else if (alContact.localImageResourceName)
    {
        UIImage *someImage = [ALUtilityClass getImageFromFramworkBundle:alContact.localImageResourceName];
        
        [contactCell.mUserImageView  setImage:someImage];
        nameIcon.hidden = YES;
    }
    else if(alContact.contactImageUrl)
    {
        NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
        [contactCell.mUserImageView sd_setImageWithURL:theUrl1];
        nameIcon.hidden = YES;
    }
    
    else
    {
        nameIcon.hidden = NO;
        NSString *firstLetter = [[alContact displayName] substringToIndex:1];
//        nameIcon.text=[firstLetter uppercaseString];
        //         contactCell.mUserImageView.hidden=YES;
        
    }
    
    return contactCell;
}

-(void)displayAttachmentMediaType:(ALMessage *)message andContactCell:(ALContactCell *)contactCell{
    
    if([message.fileMeta.contentType isEqual:@"image/jpeg"]||[message.fileMeta.contentType isEqual:@"image/png"]
       ||[message.fileMeta.contentType isEqual:@"image/gif"]||[message.fileMeta.contentType isEqual:@"image/tiff"]
       ||[message.fileMeta.contentType isEqual:@"video/mp4"])
    {
        contactCell.mMessageLabel.hidden = YES;
        contactCell.imageMarker.hidden = NO;
        contactCell.imageNameLabel.hidden = NO;
        
        if([message.fileMeta.contentType isEqual:@"video/mp4"])
        {
            //            contactCell.imageNameLabel.text = NSLocalizedString(@"MEDIA_TYPE_VIDEO", nil);
            contactCell.imageNameLabel.text = NSLocalizedString(@"Video", nil);
            contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"applozic_ic_action_video.png"];
        }
        else
        {
            // contactCell.imageNameLabel.text = NSLocalizedString(@"MEDIA_TYPE_IMAGE", nil);
            contactCell.imageNameLabel.text = NSLocalizedString(@"Image", nil);
        }
    }
    else if (message.message.length == 0)           //other than video and image
    {
        //        contactCell.imageNameLabel.text = NSLocalizedString(@"MEDIA_TYPE_ATTACHMENT", nil);
        contactCell.imageNameLabel.text = NSLocalizedString(@"Attachment", nil);
        contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_attachment.png"];
    }
    else
    {
        contactCell.imageNameLabel.hidden = YES;
        contactCell.imageMarker.hidden = YES;
    }
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Delegate Methods                 //method to enter achat/ select aparticular cell in table
//------------------------------------------------------------------------------------------------------------------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALMessage * message =  self.mContactsMessageListArray[indexPath.row];
    
    if([[message groupId] intValue])
    {
        self.channelKey = [message groupId];
    }
    else
    {
        self.channelKey = nil;
    }
    [self createDetailChatViewController: message.contactIds];
}

-(void)createDetailChatViewController: (NSString *) contactIds
{   NSLog(@"Creating Detail VC");
    if (!(self.detailChatViewController))
    {
        _detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    _detailChatViewController.contactIds = contactIds;
    if([self.channelKey intValue])
    {
        self.detailChatViewController.channelKey = self.channelKey;
    }
    else
    {
        self.detailChatViewController.channelKey = nil;
    }
    [self.navigationController pushViewController:_detailChatViewController animated:YES];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Editing Methods
//------------------------------------------------------------------------------------------------------------------

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"Delete Pressed");
        ALMessage * alMessageobj=  self.mContactsMessageListArray[indexPath.row];
        
        [ALMessageService deleteMessageThread:alMessageobj.contactIds withCompletion:^(NSString *string, NSError *error) {
            
            if(error){
                NSLog(@"failure %@",error.description);
                [ ALUtilityClass displayToastWithMessage:@"Delete failed" ];
                return;
            }
            
            NSArray * theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIds = %@",alMessageobj.contactIds]];
            
            NSLog(@"getting filteredArray ::%lu", (unsigned long)theFilteredArray.count);
            [self.mContactsMessageListArray removeObjectsInArray:theFilteredArray ];
            [self emptyConversationAlertLabel];
            [self.mTableView reloadData];
        }];
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
    if (theLatestMessage != nil && ![theMessage.createdAtTime isEqualToNumber: theLatestMessage.createdAtTime]) {
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


//------------------------------------------------------------------------------------------------------------------
#pragma mark - MQTT Service delegate methods
//------------------------------------------------------------------------------------------------------------------
-(void) syncCall:(ALMessage *) alMessage {
    ALMessageDBService *dBService = [ALMessageDBService new];
    dBService.delegate = self;
    
    [self.detailChatViewController setRefresh: YES];
    if ([self.detailChatViewController contactIds] != nil) {
        // NSLog(@"executing if part...");
        
        //Todo: set value of updateUI and [self.detailChatViewController contactIds] with actual contactId of the message
        [self.detailChatViewController syncCall:alMessage.contactIds updateUI:[NSNumber numberWithInt: 1] alertValue:alMessage.message];
    } else {
        // NSLog(@"executing else part....");
        [dBService fetchAndRefreshQuickConversation];  // can be used also instead of syncCall/syncCall:blah blah
    }
}

-(void) delivered:(NSString *)messageKey contactId:(NSString *)contactId {
    if ([[self.detailChatViewController contactIds] isEqualToString: contactId]) {
        [self.detailChatViewController updateDeliveryReport: messageKey];
    }
}

-(void) updateDeliveryStatusForContact: (NSString *) contactId {
    if ([[self.detailChatViewController contactIds] isEqualToString: contactId]) {
        [self.detailChatViewController updateDeliveryReportForConversation];
    }
}



-(void) updateTypingStatus:(NSString *)applicationKey userId:(NSString *)userId status:(BOOL)status
{
    // NSLog(@"==== Received typing status %d for: %@ ====", status, userId);
    
    if ([self.detailChatViewController.contactIds isEqualToString:userId])
    {
        [self.detailChatViewController showTypingLabel:status userId:userId];
    }
}

-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail
{
    [self.detailChatViewController setRefreshMainView:YES];
    
    if ([self.detailChatViewController.contactIds isEqualToString:alUserDetail.userId])
    {
        [self.detailChatViewController updateLastSeenAtStatus:alUserDetail];
    }
    else
    {
        ALContactCell *contactCell = [self getCell:alUserDetail.userId];
        if(alUserDetail.connected)
        {
            [contactCell.onlineImageMarker setHidden:NO];
        }
        else
        {
            [contactCell.onlineImageMarker setHidden:YES];
        }
    }
}

-(void) mqttConnectionClosed {
    
    if (_mqttRetryCount > MQTT_MAX_RETRY || !self.getVisibleState) {
        return;
    }
    
    if([ALDataNetworkConnection checkDataNetworkAvailable])
        NSLog(@"MQTT connection closed, subscribing again: %lu", (long)_mqttRetryCount);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ALMessageVC subscribing channel again....");
        [_alMqttConversationService subscribeToConversation];
    });
    _mqttRetryCount++;
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark -END
//------------------------------------------------------------------------------------------------------------------

-(void) callLastSeenStatusUpdate {
    
    [ALUserService getLastSeenUpdateForUsers:[ALUserDefaultsHandler getLastSeenSyncTime]  withCompletion:^(NSMutableArray * userDetailArray)
     {
         for(ALUserDetail * userDetail in userDetailArray){
             [ self updateLastSeenAtStatus:userDetail ];
         }
         
     }];
    
    
}

-(void)pushNotificationhandler:(NSNotification *) notification{
    NSString * contactId = notification.object;
    NSDictionary *dict = notification.userInfo;
    NSNumber *updateUI = [dict valueForKey:@"updateUI"];
    
    if (self.isViewLoaded && self.view.window && [updateUI boolValue])
    {
        [self syncCall:nil];
    }
    else if(![updateUI boolValue])
    {
        NSLog(@"#################It should never come here");
        [self createDetailChatViewController: contactId];
        [self.detailChatViewController fetchAndRefresh];
        [self.detailChatViewController setRefresh: YES];
    }
    
}

- (void)dealloc{
    
//    NSLog(@"dealloc called. Unsubscribing with mqtt.");
}
- (IBAction)backButtonAction:(id)sender {
    
    UIViewController *  uiController = [self.navigationController popViewControllerAnimated:YES];
    
    if(!uiController){
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
    
}
-(BOOL)getVisibleState{
    
    if( (self.isViewLoaded && self.view.window) ||(_detailChatViewController && _detailChatViewController.isViewLoaded && _detailChatViewController.view.window )) {
        // viewController is visible
        NSLog(@"view is visible");
        return YES;
    }else {
        NSLog(@"view is not visible");
        
        return NO;
    }
}


-(UIView *)setCustomBackButton:(NSString *)text
{
    UIImageView *imageView=[[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , @"back".length, 15)];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    //    [button addSubview:view];
    [view addSubview:button];
    return view;
    
}
-(void)back:(id)sender {
    
    UIViewController *  uiController = [self.navigationController popViewControllerAnimated:YES];
    
    if(!uiController){
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
