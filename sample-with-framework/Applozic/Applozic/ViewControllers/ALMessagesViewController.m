//
//  ViewController.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#define NAVIGATION_TEXT_SIZE 20
#define USER_NAME_LABEL_SIZE 18
#define MESSAGE_LABEL_SIZE 14
#define TIME_LABEL_SIZE 12
#define IMAGE_NAME_LABEL_SIZE 14

#import "UIView+Toast.h"
#import "TSMessageView.h"
#import "ALMessagesViewController.h"
#import "ALConstant.h"
#import "ALMessageService.h"
#import "ALMessage.h"
#import "ALUtilityClass.h"
#import "ALContact.h"
#import "ALMessageDBService.h"
#import "ALRegisterUserClientService.h"
#import "ALDBHandler.h"
#import "ALContact.h"
#import "ALUserDefaultsHandler.h"
#import "ALContactDBService.h"
#import "UIImageView+WebCache.h"
#import "ALColorUtility.h"
#import "ALMQTTConversationService.h"
#import "ALApplozicSettings.h"
#import "ALDataNetworkConnection.h"
#import "ALUserService.h"
#import "ALChannelDBService.h"
#import "ALChannel.h"
#import "ALChatLauncher.h"
#import "ALChannelService.h"
#import "ALNotificationView.h"
#import "ALPushAssist.h"
#import "ALUserDetail.h"
#import "ALContactService.h"
#import "ALConversationClientService.h"
#import "ALPushNotificationService.h"
#import "ALPushAssist.h"

// Constants
#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64
#define MQTT_MAX_RETRY 3



//------------------------------------------------------------------------------------------------------------------
// Private interface
//------------------------------------------------------------------------------------------------------------------

@interface ALMessagesViewController ()<UITableViewDataSource, UITableViewDelegate, ALMessagesDelegate, ALMQTTConversationDelegate>

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
@property (nonatomic, strong) NSNumber *unreadCount;
@property (strong, nonatomic) UILabel *emptyConversationText;
//@property (strong, nonatomic) NSNumber *channelKey;
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

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _mqttRetryCount = 0;
    
    [self setUpView];
    [self setUpTableView];
    self.mTableView.allowsMultipleSelectionDuringEditing = NO;
    [self.mActivityIndicator startAnimating];
    
    ALMessageDBService * dBService = [ALMessageDBService new];
    dBService.delegate = self;
    [dBService getMessages];

    _alMqttConversationService = [ALMQTTConversationService sharedInstance];
    _alMqttConversationService.mqttConversationDelegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alMqttConversationService subscribeToConversation];
    });
    
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                           self.view.frame.size.height/2 - navigationHeight,
                                                                           self.view.frame.size.width, 30)];
    
    [self.emptyConversationText setText:[ALApplozicSettings getEmptyConversationText]];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.emptyConversationText];
    self.emptyConversationText.hidden =  YES;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton:[ALApplozicSettings getTitleForBackButtonMsgVC]]];
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
    
    if((self.channelKey || self.userIdToLaunch))
    {
        [self createAndLaunchChatView ];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (self.navigationController.viewControllers.count == 1){
        NSLog(@" closing mqtt connections...");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alMqttConversationService unsubscribeToConversation];
        });
    }
}

-(void)dropShadowInNavigationBar
{
    //  self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationController.navigationBar.layer.shadowRadius = 10;
    self.navigationController.navigationBar.layer.masksToBounds = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    //[self dropShadowInNavigationBar];
  
    [self.navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
    
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    
    if ([_detailChatViewController refreshMainView])
    {
        ALMessageDBService *dBService = [ALMessageDBService new];
        dBService.delegate = self;
        [dBService getMessages];
        [_detailChatViewController setRefreshMainView:FALSE];
        [self.mTableView reloadData];
    }
    
    if([ALUserDefaultsHandler isLogoutButtonHidden])
    {
        [self.navBar setRightBarButtonItems:nil];
    }
    if([ALApplozicSettings getCustomNavRightButtonMsgVC])
    {
        UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self
                                                                                        action:@selector(refreshMessageList)];
        [self.navigationItem setRightBarButtonItem:refreshButton];
        
    }
    if([ALUserDefaultsHandler isBackButtonHidden])
    {
        [self.navBar setLeftBarButtonItems:nil];
    }

    
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
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(newMessageHandler:) name:NEW_MESSAGE_NOTIFICATION  object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(reloadTable:) name:@"reloadTable"  object:nil];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(updateLastSeenAtStatusPUSH:) name:@"update_USER_STATUS"  object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEntersForegroundIntoListView:)
                                                 name:@"appCameInForeground" object:nil];

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
    }

    [self callLastSeenStatusUpdate];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.detailChatViewController.contactIds = nil;
    self.detailChatViewController.channelKey = nil;
    self.detailChatViewController.conversationId = nil;
    
    if([self.mActivityIndicator isAnimating])
    {
        [self.emptyConversationText setHidden:YES];
    }
    else
    {
        [self emptyConversationAlertLabel];
    }
    
    if (![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [self noDataNotificationView];
    }
}

-(void)refreshMessageList
{
    
    [self.view makeToast:@"Syncing messages with the server,\n it might take few mins!"
                duration:1.0
                position:CSToastPositionBottom
                   title:nil];
    [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray  * messageList, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR: IN REFRESH MSG VC :: %@",error);
            return;
        }
        NSLog(@"REFRESH MSG VC");
        
    }];
}

-(void)appEntersForegroundIntoListView:(id)sender
{
    [self callLastSeenStatusUpdate];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
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

-(void)setUpView
{
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    if (!color)
    {
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
    
}

-(void)setUpTableView {
    self.mContactsMessageListArray = [NSMutableArray new];
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationTableNotification:) name:@"updateConversationTableNotification" object:nil];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - ALMessagesDelegate
//------------------------------------------------------------------------------------------------------------------
-(void)reloadTable:(NSNotification*)notification{
    
    [self updateMessageList:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:@"reloadTable"];
}

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

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Update Message List
//------------------------------------------------------------------------------------------------------------------
-(void)updateMessageList:(NSMutableArray *)messagesArray {
    NSUInteger index = 0;
    if(messagesArray.count)
    {
        [self.emptyConversationText setHidden:YES];
    }
    BOOL isreloadRequire = false;
    for (ALMessage *msg  in  messagesArray)
    {
        ALContactCell *contactCell;
       
        if(msg.groupId){
            msg.contactIds=NULL;
            contactCell =[self getCellForGroup:msg.groupId];
            
        }else {
            contactCell = [self getCell:msg.contactIds];
        }

        if(contactCell)
        {
            contactCell.mMessageLabel.text = msg.message;
            ALContactDBService * contactDBService = [[ALContactDBService alloc] init];
            ALContact *alContact = [contactDBService loadContactByKey:@"userId" value:msg.contactIds];
            ALChannelDBService * channelDBService =[[ALChannelDBService alloc] init];
            ALChannel * channel = [channelDBService loadChannelByKey:msg.groupId];

            if(alContact.connected && [ALApplozicSettings getVisibilityForOnlineIndicator])
            {
                [contactCell.onlineImageMarker setHidden:NO];
            }
            else
            {
                [contactCell.onlineImageMarker setHidden:YES];
            }
            
            if((alContact.block || alContact.blockBy))
            {
                [contactCell.onlineImageMarker setHidden:YES];
            }
            
            if(![msg.type isEqualToString:@"5"]){
                [contactCell.unreadCountLabel setHidden:NO];
            }
            
            if ([msg.type integerValue] == [FORWARD_STATUS integerValue])
                contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_forward.png"];
            else if ([msg.type integerValue] == [REPLIED_STATUS integerValue])
                contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_reply.png"];
            
            BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[msg.createdAtTime doubleValue]/1000]];
            contactCell.mTimeLabel.text = [msg getCreatedAtTime:isToday];
            if(msg.fileMeta){
                [self displayAttachmentMediaType:msg andContactCell: contactCell];
            }else if (msg.contentType==ALMESSAGE_CONTENT_LOCATION){
                  // location..
                    contactCell.mMessageLabel.hidden = YES;
                    contactCell.imageNameLabel.hidden = NO;
                    contactCell.imageMarker.hidden = NO;
                    contactCell.imageNameLabel.text = NSLocalizedString(@"Location", nil);
                    contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"location_filled.png"];
            }else{
                contactCell.imageNameLabel.hidden = YES;
                contactCell.imageMarker.hidden = YES;
                contactCell.mMessageLabel.hidden=NO;
                contactCell.mMessageLabel.text = msg.message;
            }
            
            if(msg.groupId && ![channel.unreadCount isEqualToNumber:[NSNumber numberWithInt:0]])
            {
                contactCell.unreadCountLabel.text = [NSString stringWithFormat:@"%@",channel.unreadCount];
            }
            else if(!msg.groupId && ![alContact.unreadCount isEqualToNumber:[NSNumber numberWithInt:0]])
            {
                contactCell.unreadCountLabel.text = [NSString stringWithFormat:@"%@",alContact.unreadCount];
            }
            else
            {
                [contactCell.unreadCountLabel setHidden:YES];
            }
            
        }

        else{
           index = [self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(ALMessage *almessage, NSUInteger idx, BOOL *stop) {
                   if (msg.groupId) {
                   return [almessage.groupId isEqualToNumber:msg.groupId];
                
               }else{
                   return [almessage.to isEqualToString:msg.to];
               }
            
              }];

            isreloadRequire = true;
            if (index != NSNotFound){
                [self.mContactsMessageListArray replaceObjectAtIndex:index withObject:msg];
            }
            else  {

                [self.mContactsMessageListArray insertObject:msg atIndex:0];
            }
            
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
                         if([message.contactIds isEqualToString:key] && (message.groupId.intValue == 0 || message.groupId == nil))
                         {

                             *stop = YES;
                             return YES;
                             
                         }
                         return NO;
                     }];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:1];
    ALContactCell *contactCell  = (ALContactCell *)[self.mTableView cellForRowAtIndexPath:path];
    return contactCell;
    
}

-(ALContactCell * ) getCellForGroup:(NSNumber *)groupKey {
    
    int index=(int) [self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop)
                     {
                         ALMessage *message = (ALMessage*)element;
                         if([message.groupId isEqualToNumber:groupKey])
                         {
                             *stop = YES;
                             return YES;
                         }
                         return NO;
                     }];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:1];
    ALContactCell *contactCell  = (ALContactCell *)[self.mTableView cellForRowAtIndexPath:path];
    return contactCell;
    
}
//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View DataSource Methods
//------------------------------------------------------------------------------------------------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (self.mTableView == nil)?0:2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:{
            if([ALApplozicSettings getGroupOption]){
                return 1;
            }
            else{
                return 0;
            }
        }break;
            
        case 1:{
            return self.mContactsMessageListArray.count>0?[self.mContactsMessageListArray count]:0;
        }break;
            
        default:
            return 0;
            break;
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALContactCell *contactCell;
    
    switch (indexPath.section) {
            
    case 0:{
        //Cell for group button....
        contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
        
        //Add group button.....
        UIButton *newBtn=(UIButton*)[contactCell viewWithTag:101];
        [newBtn addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
        newBtn.userInteractionEnabled=YES;
        
    }break;

    case 1:{
        //Add rest of messageList
        contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        
        [contactCell.mUserNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:USER_NAME_LABEL_SIZE]];
        [contactCell.mMessageLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_LABEL_SIZE]];
        [contactCell.mTimeLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:TIME_LABEL_SIZE]];
        [contactCell.imageNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:IMAGE_NAME_LABEL_SIZE]];
        
        contactCell.unreadCountLabel.backgroundColor = [ALApplozicSettings getUnreadCountLabelBGColor];
        contactCell.unreadCountLabel.layer.cornerRadius = contactCell.unreadCountLabel.frame.size.width/2;
        contactCell.unreadCountLabel.layer.masksToBounds = YES;
        
        contactCell.mUserImageView.hidden = NO;
        contactCell.mUserImageView.layer.cornerRadius = contactCell.mUserImageView.frame.size.width/2;
        contactCell.mUserImageView.layer.masksToBounds = YES;

        [contactCell.onlineImageMarker setBackgroundColor:[UIColor clearColor]];
        
        UILabel* nameIcon = (UILabel*)[contactCell viewWithTag:102];
        nameIcon.textColor = [UIColor whiteColor];

        ALMessage *message = (ALMessage *)self.mContactsMessageListArray[indexPath.row];
        
        ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [contactDBService loadContactByKey:@"userId" value: message.to];
        
        ALChannelDBService * channelDBService =[[ALChannelDBService alloc] init];
        ALChannel * alChannel = [channelDBService loadChannelByKey:message.groupId];
        
        if([message.groupId intValue])
        {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService getChannelInformation:message.groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel)
            {
                contactCell.mUserNameLabel.text = [alChannel name];
                contactCell.onlineImageMarker.hidden=YES;
            }];
        }
        else
        {
            contactCell.mUserNameLabel.text = [alContact getDisplayName];
        }
        
        contactCell.mMessageLabel.text = message.message;
        contactCell.mMessageLabel.hidden = NO;
        
        if ([message.type integerValue] == [FORWARD_STATUS integerValue])
            contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_forward.png"];
        else if ([message.type integerValue] == [REPLIED_STATUS integerValue])
            contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_reply.png"];
        
        BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
        contactCell.mTimeLabel.text = [message getCreatedAtTime:isToday];
        
        [self displayAttachmentMediaType:message andContactCell:contactCell];
        
        // here for msg dashboard profile pic
       
        [nameIcon setText:[ALColorUtility getAlphabetForProfileImage:[alContact getDisplayName]]];
        
        if([message getGroupId])
        {
            [contactCell.onlineImageMarker setHidden:YES];
        }
        else if(alContact.connected && [ALApplozicSettings getVisibilityForOnlineIndicator])
        {
            [contactCell.onlineImageMarker setHidden:NO];
        }
        else
        {
            [contactCell.onlineImageMarker setHidden:YES];
        }

        if(alContact.block || alContact.blockBy)
        {
            [contactCell.onlineImageMarker setHidden:YES];
        }
        
        BOOL zeroContactCount = (alContact.unreadCount.intValue == 0  ? true:false);
        BOOL zeroChannelCount = (alChannel.unreadCount.intValue == 0  ? true:false);
        
        if(zeroChannelCount || zeroContactCount)
        {
            contactCell.unreadCountLabel.text = @"";
            [contactCell.unreadCountLabel setHidden:YES];
        }
        
        if(!zeroContactCount && [alContact userId] && (message.groupId.intValue == 0 || message.groupId == NULL)){
            [contactCell.unreadCountLabel setHidden:NO];
            contactCell.unreadCountLabel.text=[NSString stringWithFormat:@"%i",alContact.unreadCount.intValue];
        }
        else if(!zeroChannelCount && [message.groupId intValue]){
            [contactCell.unreadCountLabel setHidden:NO];
            contactCell.unreadCountLabel.text = [NSString stringWithFormat:@"%i",alChannel.unreadCount.intValue];
        }
    
        contactCell.mUserImageView.backgroundColor = [UIColor whiteColor];
        if([message.groupId intValue])
        {
            
            [contactCell.mUserImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"applozic_group_icon.png"]];
            NSURL * imageUrl = [NSURL URLWithString:alChannel.channelImageURL];
            if(imageUrl)
            {
                [contactCell.mUserImageView sd_setImageWithURL:imageUrl];
            }
            
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
            [contactCell.mUserImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            contactCell.mUserImageView.backgroundColor = [ALColorUtility getColorForAlphabet:[alContact getDisplayName]];
        }
    
    }break;
            
        default:
            break;
    }

    
    return contactCell;
}

-(void)displayAttachmentMediaType:(ALMessage *)message andContactCell:(ALContactCell *)contactCell{
    
    contactCell.mMessageLabel.hidden = YES;
    contactCell.imageMarker.hidden = NO;
    contactCell.imageNameLabel.hidden = NO;

    if([message.fileMeta.contentType hasPrefix:@"image"])
    {
//        contactCell.imageNameLabel.text = NSLocalizedString(@"MEDIA_TYPE_IMAGE", nil);
        contactCell.imageNameLabel.text = NSLocalizedString(@"Image", nil);
        contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_camera.png"];
    }
    else if([message.fileMeta.contentType hasPrefix:@"video"])
    {
        //            contactCell.imageNameLabel.text = NSLocalizedString(@"MEDIA_TYPE_VIDEO", nil);
        contactCell.imageNameLabel.text = NSLocalizedString(@"Video", nil);
        contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_video.png"];
    }
    else if (message.contentType == ALMESSAGE_CONTENT_LOCATION)   // location..
    {
        contactCell.mMessageLabel.hidden = YES;
        contactCell.imageNameLabel.text = NSLocalizedString(@"Location", nil);
        contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"location_filled.png"];
    }
    else if (message.fileMeta.contentType)           //other than video and image
    {
//        contactCell.imageNameLabel.text = NSLocalizedString(@"MEDIA_TYPE_ATTACHMENT", nil);
        contactCell.imageNameLabel.text = NSLocalizedString(@"Attachment", nil);
        contactCell.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_attachment.png"];
    }
    
    else
    {
        contactCell.imageNameLabel.hidden = YES;
        contactCell.imageMarker.hidden = YES;
        contactCell.mMessageLabel.hidden = NO;
    }
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Delegate Methods                 
//------------------------------------------------------------------------------------------------------------------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if(indexPath.section != 0)
    {
        ALMessage * message = self.mContactsMessageListArray[indexPath.row];
        [self createDetailChatViewControllerWithMessage:message];
        ALContactCell * contactCell = (ALContactCell *)[tableView cellForRowAtIndexPath:indexPath];
        int count = [contactCell.unreadCountLabel.text intValue];
        if(count)
        {
            self.detailChatViewController.refresh = YES;
        }
    }
}

-(void)createDetailChatViewController: (NSString *) contactIds
{
    if (!(self.detailChatViewController))
    {
        self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    self.detailChatViewController.contactIds = contactIds;
    self.detailChatViewController.chatViewDelegate = self;
    self.detailChatViewController.channelKey = self.channelKey;
    [self.navigationController pushViewController:_detailChatViewController animated:YES];
}

-(void)createDetailChatViewControllerWithMessage: (ALMessage *) message
{   
    if (!(self.detailChatViewController))
    {
        self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    
    if(message.conversationId){
        self.detailChatViewController.conversationId = message.conversationId;
    }
    
    if (message.groupId)
    {
        self.detailChatViewController.channelKey = message.groupId;
        self.detailChatViewController.contactIds = nil;
    }
    else
    {
        self.detailChatViewController.contactIds = message.contactIds;
    }
    
    self.detailChatViewController.chatViewDelegate = self;
    [self.navigationController pushViewController:_detailChatViewController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        tableView.rowHeight=40.0;
    }
    else{
        tableView.rowHeight=81.5;
    }
    
    return tableView.rowHeight;
}
//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Editing Methods
//------------------------------------------------------------------------------------------------------------------

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        return NO;
    }
    else{
        return YES;
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        NSLog(@"Delete Pressed");
        if(![ALDataNetworkConnection checkDataNetworkAvailable])
        {
            [self noDataNotificationView];
            return;
        }
        ALMessage * alMessageobj = self.mContactsMessageListArray[indexPath.row];
        
        ALChannelService *channelService = [ALChannelService new];
        if([channelService isChannelLeft:[alMessageobj getGroupId]])
        {
            NSArray * filteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                       [NSPredicate predicateWithFormat:@"groupId = %@",[alMessageobj getGroupId]]];
            
            ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
            [dbService deleteAllMessagesByContact:nil orChannelKey:[alMessageobj getGroupId]];
            [ALChannelService setUnreadCountZeroForGroupID:[alMessageobj getGroupId]];
            [self subProcessDeleteMessageThread:filteredArray];
            
            return;
        }
        
        [ALMessageService deleteMessageThread:alMessageobj.contactIds orChannelKey:[alMessageobj getGroupId] withCompletion:^(NSString *string, NSError *error) {
            
            if(error)
            {
                NSLog(@"DELETE_FAILED_CONVERSATION_ERROR_DESCRIPTION : %@", error.description);
                [ALUtilityClass displayToastWithMessage:@"Delete failed"];
                return;
            }
            NSArray * theFilteredArray;
            if([alMessageobj getGroupId])
            {

                theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                    [NSPredicate predicateWithFormat:@"groupId = %@",[alMessageobj getGroupId]]];
            }
            else
            {
                theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                    [NSPredicate predicateWithFormat:@"contactIds = %@",alMessageobj.contactIds]];
            }
            
            [self subProcessDeleteMessageThread:theFilteredArray];
        }];
    }
}

-(void)subProcessDeleteMessageThread:(NSArray *)theFilteredArray
{
    NSLog(@"getting filtered Array :: %lu", (unsigned long)theFilteredArray.count);
    [self.mContactsMessageListArray removeObjectsInArray:theFilteredArray];
    [self emptyConversationAlertLabel];
    [self.mTableView reloadData];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Notification observers
//------------------------------------------------------------------------------------------------------------------

-(void) updateConversationTableNotification:(NSNotification *) notification
{
    ALMessage * theMessage = notification.object;
    NSLog(@"notification for table update...%@", theMessage.message);
    NSArray * theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIds = %@",theMessage.contactIds]];
    //check for group id also
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

-(void)reloadDataForUserBlockNotification:(NSString *)userId andBlockFlag:(BOOL)flag
{
    [self.detailChatViewController checkUserBlockStatus];
    
    if([[ALPushAssist new] isMessageViewOnTop])
    {
        [self.detailChatViewController.label setHidden:YES];
        
        ALContactCell * contactCell = [self getCell:userId];
        if(contactCell && [ALApplozicSettings getVisibilityForOnlineIndicator])
        {
            [contactCell.onlineImageMarker setHidden:flag];
        }
        
    }
}

-(void) syncCall:(ALMessage *) alMessage andMessageList:(NSMutableArray *)messageArray
{
    ALMessageDBService *dBService = [ALMessageDBService new];
    dBService.delegate = self;
    
    ALPushAssist* top=[[ALPushAssist alloc] init];
    [self.detailChatViewController setRefresh: YES];
    
    if ([self.detailChatViewController contactIds] != nil || [self.detailChatViewController channelKey] !=nil) {
        
        [self.detailChatViewController syncCall:alMessage updateUI:[NSNumber numberWithInt:APP_STATE_ACTIVE] alertValue:alMessage.message];
    }
    else if (top.isMessageViewOnTop && (![alMessage.type isEqualToString:@"5"])) {

        [self updateMessageList:messageArray];
        ALNotificationView * alnotification = [[ALNotificationView alloc]
                                               initWithAlMessage:alMessage
                                               withAlertMessage:alMessage.message];
        [alnotification nativeNotification:self];
    }
}

-(void) delivered:(NSString *)messageKey contactId:(NSString *)contactId withStatus:(int)status {
    if (messageKey != nil) {
        [self.detailChatViewController updateDeliveryReport:messageKey withStatus:status];
    }
    
}

-(void) updateStatusForContact: (NSString *) contactId withStatus:(int)status {
    if ([[self.detailChatViewController contactIds] isEqualToString: contactId]) {
        [self.detailChatViewController updateStatusReportForConversation:status];
    }
}

-(void) updateTypingStatus:(NSString *)applicationKey userId:(NSString *)userId status:(BOOL)status
{
    NSLog(@"==== (MSG_VC) Received typing status %d for: %@ ====", status, userId);
    ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [contactDBService loadContactByKey:@"userId" value: userId];
    if((alContact.block || alContact.blockBy) && !self.detailChatViewController.channelKey)
    {
        return;
    }
    if ([self.detailChatViewController.contactIds isEqualToString:userId] || self.detailChatViewController.channelKey)
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
        [contactCell.onlineImageMarker setHidden:YES];
        if(alUserDetail.connected && [ALApplozicSettings getVisibilityForOnlineIndicator])
        {
            [contactCell.onlineImageMarker setHidden:NO];
        }
        
        ALContactDBService * contactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [contactDBService loadContactByKey:@"userId" value:alUserDetail.userId];
        
        if(alContact.block || alContact.blockBy)
        {
            [contactCell.onlineImageMarker setHidden:YES];
        }
        
    }
    

}

-(void)updateLastSeenAtStatusPUSH:(NSNotification*)notification{
    [self updateLastSeenAtStatus:notification.object];
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
    
    NSArray *myArray =  [contactId componentsSeparatedByCharactersInSet:
     [NSCharacterSet characterSetWithCharactersInString:@":"]];
    if(myArray.count>2){
        self.channelKey =  @([ myArray[1] intValue]);
    }
    else{
        self.channelKey = nil;
    }
    
    NSDictionary *dict = notification.userInfo;
    NSNumber * updateUI = [dict valueForKey:@"updateUI"];
    NSString * alertValue =  [dict valueForKey:@"alertValue" ];
    
    if (self.isViewLoaded && self.view.window
        && [updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_ACTIVE]] )
    {
        ALMessage *msg = [[ALMessage alloc]init];
        msg.message=alertValue;
        NSArray *myArray = [msg.message
                            componentsSeparatedByCharactersInSet:
                            [NSCharacterSet characterSetWithCharactersInString:@":"]];
        
        if(myArray.count>1){
            alertValue=[NSString stringWithFormat:@"%@",myArray[1]];
        }
        else{
            alertValue=myArray[0];
        }
        msg.message=alertValue;
        msg.contactIds = contactId;
        msg.groupId = self.channelKey;

        [self syncCall:msg andMessageList:nil];

    }
    else if([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_INACTIVE]]){
       
        NSLog(@"#################It should never come here");
        [self createDetailChatViewController: contactId];
//      [self.detailChatViewController fetchAndRefresh];
        [self.detailChatViewController setRefresh: YES];
    }
    else if([NSNumber numberWithInt:APP_STATE_BACKGROUND]){
        /*
         # Synced before already!
         # NSLog(@"APP_STATE_BACKGROUND HANDLER");
        */
    }
    

}

- (void)dealloc{
    
    //    NSLog(@"dealloc called. Unsubscribing with mqtt.");
     [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    UIImageView *imageView = [[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , 20, 15)];
    [label setTextColor: [ALApplozicSettings getColorForNavigationItem]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    
//    UIButton * button = [[UIButton alloc] initWithFrame:view.frame];
//    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    backTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:backTap];

    
    //    [button addSubview:view];
//    [view addSubview:button];
    return view;
    
}
-(void)back:(id)sender {
    
    UIViewController *  uiController = [self.navigationController popViewControllerAnimated:YES];
    
    if(!uiController){
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"will enter foreground notification");
   // [self syncCall:nil];
    //[self callLastSeenStatusUpdate];
}

-(void)newMessageHandler:(NSNotification *) notification{
    
    NSMutableArray * messageArray = notification.object;
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    [messageArray sortUsingDescriptors:descriptors];
    [self updateMessageList:messageArray];
    
    if(self.mqttRetryCount >= 3)
    {
        self.mqttRetryCount = 0;
    }
}

- (IBAction)createGroup:(id)sender
{
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [self noDataNotificationView];
        return;
    }
    ALNewContactsViewController * contactsVC = [[ALNewContactsViewController alloc] init];
    contactsVC.delegate = self;

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController *groupCreation = [storyboard instantiateViewControllerWithIdentifier:@"ALGroupCreationViewController"];
    [self.navigationController pushViewController:groupCreation animated:YES];
}

-(void)noDataNotificationView
{
    ALNotificationView * notification = [ALNotificationView new];
    [notification noDataConnectionNotificationView];
}

-(void)createAndLaunchChatView
{
    if (!(self.detailChatViewController))
    {
        self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    self.detailChatViewController.contactIds = self.userIdToLaunch;
    self.detailChatViewController.channelKey = self.channelKey;
    self.detailChatViewController.chatViewDelegate = self;
    [self.detailChatViewController serverCallForLastSeen];
    
    [self.navigationController pushViewController:_detailChatViewController animated:NO];
}

-(void)insertChannelMessage:(NSNumber *)channelKey
{
    ALMessage * channelMessage = [ALMessage new];
    channelMessage.groupId = channelKey;
    NSMutableArray * grpMesgArray = [[NSMutableArray alloc] initWithObjects:channelMessage, nil];
    [self updateMessageList:grpMesgArray];
}

// CHAT VIEW DELEGATE FOR PUSH Custom VC
-(void)handleCustomActionFromChatVC:(UIViewController *)chatViewController andWithMessage:(ALMessage *)alMessage
{
    [self.messagesViewDelegate handleCustomActionFromMsgVC:chatViewController andWithMessage:alMessage];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"END_SCROCLLING_TRY");
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    
    if(y > (h - reload_distance))
    {
       [self fetchMoreMessages:scrollView];
    }
}

-(void)fetchMoreMessages:(UIScrollView*)aScrollView
{
    ALMessageDBService * dBService = [ALMessageDBService new];
    dBService.delegate = self;
    [self.mActivityIndicator startAnimating];
    [self.mTableView setUserInteractionEnabled:NO];
    
    if(![ALUserDefaultsHandler getFlagForAllConversationFetched])
    {
        [dBService fetchConversationfromServerWithCompletion:^(BOOL flag) {
           
            [self.mActivityIndicator stopAnimating];
            [self.mTableView setUserInteractionEnabled:YES];
            
        }];
    }
    else
    {
        if([ALApplozicSettings getVisibilityForNoMoreConversationMsgVC])
        {
            [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
            [TSMessage showNotificationWithTitle:@"No more conversations" type:TSMessageNotificationTypeWarning];
        }
            [self.mActivityIndicator stopAnimating];
            [self.mTableView setUserInteractionEnabled:YES];
    }
}

@end
