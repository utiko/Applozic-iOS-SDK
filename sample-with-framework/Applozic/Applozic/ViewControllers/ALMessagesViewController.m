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
#import "Reachability.h"
#import "ALUserService.h"

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
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;


-(void)reachabilityChanged:(NSNotification*)note;

@property(strong) Reachability * googleReach;
@property(strong) Reachability * localWiFiReach;
@property(strong) Reachability * internetConnectionReach;


// Private Variables
@property (nonatomic) NSInteger mqttRetryCount;
@property (nonatomic, strong) NSMutableArray * mContactsMessageListArray;
@property (nonatomic, strong) UIColor *navColor;
@property (nonatomic,strong) NSArray *unreadCount;
@property (nonatomic,strong) NSArray* colors;
@property (strong, nonatomic) UILabel *emptyConversationText;
@property (strong, nonatomic) UILabel *dataAvailablityLabel;
@end

// $$$$$$$$$$$$$$$$$A Class Extension for solving Constraints Issues.$$$$$$$$$$$$$$$$$$$$
@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

@implementation ALMessagesViewController

ALMQTTConversationService *alMqttConversationService;

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
    alMqttConversationService = [ALMQTTConversationService sharedInstance];
    alMqttConversationService.mqttConversationDelegate = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [alMqttConversationService subscribeToConversation];
    });
    
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 15 + self.view.frame.size.width/8, self.view.frame.origin.y + self.view.frame.size.height/2, 250, 30)];
    [self.emptyConversationText setText:@"You have no conversations yet"];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.emptyConversationText];
    
    self.dataAvailablityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.tabBarController.tabBar.frame.origin.y - 30, self.view.frame.size.width, 30)];
    [self.dataAvailablityLabel setText:@"NO INTERNET CONNECTION"];
    [self.dataAvailablityLabel setBackgroundColor:[UIColor colorWithRed:179.0/255 green:32.0/255 blue:35.0/255 alpha:1]];
    [self.dataAvailablityLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dataAvailablityLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.dataAvailablityLabel];
    
    [self viewDidLoadPart];
}

-(void) ViewDidUnload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [alMqttConversationService unsubscribeToConversation];
    });
}

-(void)viewDidLoadPart
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // create a Reachability object for www.google.com
    
    self.googleReach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    self.googleReach.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Block Says Reachable(%@)", reachability.currentReachabilityString];
       // NSLog(@"%@", temp);
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this uses NSOperationQueue mainQueue
        
    };
    
    self.googleReach.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Block Says Unreachable(%@)", reachability.currentReachabilityString];
      //  NSLog(@"%@", temp);
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this one uses dispatch_async they do the same thing (as above)
        
    };
    
    [self.googleReach startNotifier];

    // create a reachability for the local WiFi
    
    self.localWiFiReach = [Reachability reachabilityForLocalWiFi];
    
    // we ONLY want to be reachable on WIFI - cellular is NOT an acceptable connectivity
    self.localWiFiReach.reachableOnWWAN = NO;
    
    self.localWiFiReach.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"LocalWIFI Block Says Reachable(%@)", reachability.currentReachabilityString];
       // NSLog(@"%@", temp);
        
        
    };
    
    self.localWiFiReach.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"LocalWIFI Block Says Unreachable(%@)", reachability.currentReachabilityString];
        
       // NSLog(@"%@", temp);
        
    };
    
    [self.localWiFiReach startNotifier];
    
    // create a Reachability object for the internet
    
    self.internetConnectionReach = [Reachability reachabilityForInternetConnection];
    
    self.internetConnectionReach.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@" InternetConnection Says Reachable(%@)", reachability.currentReachabilityString];
       // NSLog(@"%@", temp);
        
        
    };
    
    self.internetConnectionReach.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"InternetConnection Block Says Unreachable(%@)", reachability.currentReachabilityString];
        
      //  NSLog(@"%@", temp);
        
    };
    
    [self.internetConnectionReach startNotifier];
    
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if(reach == self.googleReach)
    {
        if([reach isReachable])
        {
            //NSLog(@"========== IF googleReach ============");
        }
        else
        {
           // NSLog(@"========== ELSE googleReach ============");
        }
    }
    else if (reach == self.localWiFiReach)
    {
        if([reach isReachable])
        {
           // NSLog(@"========== IF localWiFiReach ============");
        }
        else
        {
           // NSLog(@"========== ELSE localWiFiReach ============");
        }
    }
    else if (reach == self.internetConnectionReach)
    {
        if([reach isReachable])
        {
           // NSLog(@"========== IF internetConnectionReach ============");
            
           
            [ALMessageService processLatestMessagesGroupByContact];
            //changes required
            

        }
        else
        {
            //NSLog(@"========== ELSE internetConnectionReach ============");
        }
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
    [self.detailChatViewController setRefreshMainView:TRUE];

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
    if (_mqttRetryCount > MQTT_MAX_RETRY) {
        return;
    }

    if([ALDataNetworkConnection checkDataNetworkAvailable])
        NSLog(@"MQTT connection closed, subscribing again: %lu", _mqttRetryCount);
            dispatch_async(dispatch_get_main_queue(), ^{
            [alMqttConversationService subscribeToConversation];
        });
    _mqttRetryCount++;
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
    [[self.navigationItem leftBarButtonItem] setTitle:[ALApplozicSettings getBackButtonTitle]];
    
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
    
    if ([_detailChatViewController refreshMainView])
    {
        ALMessageDBService *dBService = [ALMessageDBService new];
        dBService.delegate = self;
        [dBService getMessages];
        [_detailChatViewController setRefreshMainView:FALSE];
    }
    
     [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:NAVIGATION_TEXT_SIZE]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColourForNavigation]];
    [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColourForNavigationItem]];
    
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
}

- (IBAction)logout:(id)sender {
    
        ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
        [registerUserClientService logout];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ALLoginViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"ALLoginViewController"];
    
       [self presentViewController:add animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

-(void)setUpView {
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    if (!color) {
     //   color = [UIColor blackColor];
        color = [UIColor whiteColor];
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
    self.colors=[[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
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
    
    return (self.mTableView==nil)?0:1;
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
    contactCell.mUserNameLabel.text = [alContact displayName];
    contactCell.mMessageLabel.text = message.message;
    contactCell.mMessageLabel.hidden = FALSE;
    if ([message.type integerValue] == [FORWARD_STATUS integerValue])
        contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_forward.png"];
    else if ([message.type integerValue] == [REPLIED_STATUS integerValue])
        contactCell.mLastMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"mobicom_social_reply.png"];
    
    BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
    contactCell.mTimeLabel.text = [message getCreatedAtTime:isToday];
    
    [self displayAttachmentMediaType:message andContactCell: contactCell];
   
    // here for msg dashboard profile pic
    NSString *firstLetter = [[[alContact displayName] substringToIndex:1] uppercaseString];
    nameIcon.text=firstLetter;
   
    if(alContact.connected)
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
        contactCell.mCountImageView.hidden=FALSE;
        unread.text=[NSString stringWithFormat:@"%lu",(unsigned long)self.unreadCount.count];
    }
    else{
        unread.hidden=TRUE;
        contactCell.mCountImageView.hidden=TRUE;
    }
    
    
    
    contactCell.mUserImageView.hidden=FALSE;
    contactCell.mUserImageView.layer.cornerRadius=contactCell.mUserImageView.frame.size.width/2;
    contactCell.mCountImageView.layer.cornerRadius=contactCell.mCountImageView.frame.size.width/2;

///////////$$$$$$$$$$$$$$$$//////////////////////COLORING//////////////////////$$$$$$$$$$$$$$$$///////////
    
    NSUInteger randomIndex = random()% [self.colors count];
    contactCell.mUserImageView.image= [ALColorUtility imageWithSize:CGRectMake(0,0,55,55)
                                                      WithHexString:self.colors[randomIndex] ];
    

///////////$$$$$$$$$$$$$$$$//////////////////////$$$$$$$$$$$$$$$$//////////////////////$$$$$$$$$$$$$$$$///////////
   
    
    if (alContact.localImageResourceName)
    {
        UIImage *someImage = [ALUtilityClass getImageFromFramworkBundle:alContact.localImageResourceName];

        [contactCell.mUserImageView  setImage:someImage];
        nameIcon.hidden = TRUE;
    }
    else if(alContact.contactImageUrl)
    {
        NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
        [contactCell.mUserImageView sd_setImageWithURL:theUrl1];
        nameIcon.hidden = TRUE;
    }
    
    else
    {
         nameIcon.hidden = FALSE;
         NSString *firstLetter = [[alContact displayName] substringToIndex:1];
         nameIcon.text=[firstLetter uppercaseString];
//         contactCell.mUserImageView.hidden=TRUE;

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
    
    [self createDetailChatViewController: message.contactIds];
    
}

-(void)createDetailChatViewController: (NSString *) contactIds
{
    if (!(self.detailChatViewController))
    {
        _detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    _detailChatViewController.contactIds = contactIds;
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
            
            NSLog(@"getting filteredArray ::%lu", (unsigned long)theFilteredArray.count );
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

-(void) syncCall:(ALMessage *) alMessage {
    ALMessageDBService *dBService = [ALMessageDBService new];
    dBService.delegate = self;
    
    [self.detailChatViewController setRefresh: TRUE];
    if ([self.detailChatViewController contactIds] != nil) {
       // NSLog(@"executing if part...");

        //Todo: set value of updateUI and [self.detailChatViewController contactIds] with actual contactId of the message
        [self.detailChatViewController syncCall:alMessage.contactIds updateUI:[NSNumber numberWithInt: 1] alertValue:alMessage.message];
    } else {
       // NSLog(@"executing else part....");
        [dBService fetchAndRefreshQuickConversation];
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
        [self.detailChatViewController setRefresh: TRUE];
    }
    
}
-(void) callLastSeenStatusUpdate {

    [ALUserService getLastSeenUpdateForUsers:[ALUserDefaultsHandler getLastSeenSyncTime]  withCompletion:^(NSMutableArray * userDetailArray)
   {
       for(ALUserDetail * userDetail in userDetailArray){
           [ self updateLastSeenAtStatus:userDetail ];
       }
      
   }];
    

}

- (void)dealloc {
    
}
- (IBAction)backButtonAction:(id)sender {
    
    UIViewController *  uiController = [self.navigationController popViewControllerAnimated:YES];
    
    if(!uiController){
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
