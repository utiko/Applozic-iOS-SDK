//
//  ALChatViewController.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "ALChatViewController.h"
#import "ALChatCell.h"
#import "ALMessageService.h"
#import "ALUtilityClass.h"
#import <CoreGraphics/CoreGraphics.h>
#import "ALJson.h"
#import <CoreData/CoreData.h>
#import "ALDBHandler.h"
#import "DB_Message.h"
#import "ALMessagesViewController.h"
#import "ALNewContactsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Utility.h"
#import "ALImageCell.h"
#import "ALFileMetaInfo.h"
#import "DB_FileMetaInfo.h"
#import "UIImageView+WebCache.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALRequestHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageDBService.h"
#import "ALImagePickerHandler.h"
#import "ALLocationManager.h"
#import "ALConstant.h"
#import "DB_Contact.h"
#import "ALMapViewController.h"
#import "ALNotificationView.h"
#import "ALUserService.h"
#import "ALMessageService.h"
#import "ALUserDetail.h"
#import "ALMQTTConversationService.h"
#import "ALContactDBService.h"
#import "ALDataNetworkConnection.h"
#import "ALAppLocalNotifications.h"
#import "ALChatLauncher.h"
#import "ALMessageClientService.h"
#import "ALContactService.h"
#import "ALMediaBaseCell.h"
#import "ALGroupDetailViewController.h"
#import "ALVideoCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALConversationService.h"

#define MQTT_MAX_RETRY 3
#define NEW_MESSAGE_NOTIFICATION @"newMessageNotification"



@interface ALChatViewController ()<ALMediaBaseCellDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,ALLocationDelegate,ALMQTTConversationDelegate,MPMediaPickerControllerDelegate, ALAudioAttachmentDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIAlertViewDelegate>

@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic,assign) int rp;
@property (nonatomic,assign) NSUInteger mTotalCount;
@property (nonatomic,retain) UIImagePickerController * mImagePicker;
@property (nonatomic)  ALLocationManager * alLocationManager;
@property (nonatomic,assign) BOOL showloadEarlierAction;
@property (weak, nonatomic) IBOutlet UIButton *loadEarlierAction;
@property (nonatomic,weak) NSIndexPath *indexPathofSelection;
@property (nonatomic,strong ) ALMQTTConversationService *mqttObject;
@property (nonatomic) NSInteger *  mqttRetryCount;
@property (nonatomic, strong) NSArray * pickerDataSourceArray;
@property (nonatomic, strong) NSMutableArray * pickerConvIdsArray;
@property (nonatomic,strong )NSMutableArray * conversationTitleList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewSendMsgTextViewConstraint;

- (IBAction)loadEarlierButtonAction:(id)sender;
-(void)processLoadEarlierMessages:(BOOL)flag;
-(void)processMarkRead;
-(void)fetchAndRefresh:(BOOL)flag;
-(void)serverCallForLastSeen;
-(void)freezeView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

-(void)processAttachment:(NSString *)filePath andMessageText:(NSString *)textwithimage andContentType:(short)contentype;

@end

@implementation ALChatViewController{
    
    UIActivityIndicatorView *loadingIndicator;
    NSString *messageId;
    BOOL typingStat;
    CGRect defaultTableRect;
    UIView * maskView;
    BOOL isPickerOpen;
    
}

ALMessageDBService  * dbService;
//------------------------------------------------------------------------------------------------------------------
#pragma mark - View lifecycle
//------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetUp];
    [self fetchMessageFromDB];
    [self loadChatView];
}

-(void)processMarkRead{
    bool isGroupNotification = (self.channelKey == nil ? false : true);
    if(self.channelKey && isGroupNotification ){
        [ALChannelService markConversationAsRead:self.channelKey withCompletion:^(NSString * string, NSError * error) {
            if(error) {
                NSLog(@"Error while marking messages as read channel %@",self.channelKey);
            }
        }];
    }

    if(self.contactIds && !self.isGroup){
        [ALUserService markConversationAsRead:self.contactIds withCompletion:^(NSString * string, NSError *error) {
            if(error) {
                NSLog(@"Error while marking messages as read for contact %@", self.contactIds);
            }
        }];
        
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
    [self.loadEarlierAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loadEarlierAction setBackgroundColor:[UIColor grayColor]];
    [self processMarkRead];
    
   
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [ALApplozicSettings getColorForNavigationItem], NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:18]}];
    [navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
    [navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(newMessageHandler:) name:NEW_MESSAGE_NOTIFICATION  object:nil];
    
    [self.tabBarController.tabBar setHidden: YES];
    
    [self.label setHidden:NO];
    [self.loadEarlierAction setHidden:YES];
    self.showloadEarlierAction = TRUE;
    self.typingLabel.hidden = YES;
    
    typingStat = NO;
    
    
    
    if([self isReloadRequired])
    {
        [self reloadView];
        
        NSString * key = self.channelKey ? [self.channelKey stringValue]: self.contactIds;
        
        if(![ALUserDefaultsHandler isServerCallDoneForMSGList:key])
        {
            //            [[self.alMessageWrapper getUpdatedMessageArray] removeAllObjects];
            //            self.startIndex =0;
            //            [self.mTableView reloadData];
            //            [self setTitle];
            [self processLoadEarlierMessages:true];
        }
        else
        {
            [super scrollTableViewToBottomWithAnimation:NO];
        }
    }
    
    if (self.refresh) {
        self.refresh = false;
    }
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(individualNotificationhandler:) name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeliveryStatus:) name:@"deliveryReport" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    self.mqttObject = [ALMQTTConversationService sharedInstance];
    
    self.mqttObject = [ALMQTTConversationService sharedInstance];
    
    
    if(self.individualLaunch){
        NSLog(@"individual launch ...subscribeToConversation to mqtt..");
        self.mqttObject.mqttConversationDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.mqttObject)
                [self.mqttObject subscribeToConversation];
            else
                NSLog(@"mqttObject is not found...");
        });
        [self serverCallForLastSeen];
    }
    
    if(self.text){
        self.sendMessageTextView.text = self.text;
    }
    
    if(self.conversationId)
    {
        [self setupPickerView];
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
        [self.pickerView reloadAllComponents];
    }    
    [self checkIfChannelLeft];
//    [self checkUserBlockStatus]; USER BLOCK COMMENTED TILL NEXT RELEASE
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden: YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deliveryReport" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MESSAGE_NOTIFICATION object:nil];
    
    [self.sendMessageTextView resignFirstResponder];
    [self.label setHidden:YES];
    [self.typingLabel setHidden:YES];
    [ [ALMediaPlayer sharedInstance] stopPlaying];
    
    if(self.individualLaunch){
        NSLog(@"ALChatVC: Individual launch ...unsubscribeToConversation to mqtt..");
        //        dispatch_async(dispatch_get_main_queue(), ^{
        if(self.mqttObject){
            [self.mqttObject unsubscribeToConversation];
            NSLog(@"ALChatVC: In ViewWillDisapper .. MQTTObject in ==IF== now");
        }
        else
            NSLog(@"mqttObject is not found...");
        //        });
        
    }
    if(isPickerOpen)
    [self donePicking:nil];
}
-(BOOL)isReloadRequired{
    
    if(self.refresh || [self.alMessageWrapper getUpdatedMessageArray].count == 0) // if refresh then obviously refresh!!
        return YES;
    
    BOOL noContactIdMatch = !([[[self.alMessageWrapper getUpdatedMessageArray][0] contactIds]  isEqualToString:self.contactIds]);
    BOOL noGroupIdMatch   = !([[[self.alMessageWrapper getUpdatedMessageArray][0]    groupId]  isEqualToNumber:self.channelKey]);
    
    
    if(noGroupIdMatch){  // No group match return YES without doubt!
        return YES;
    }
    else if (self.channelKey==nil && noContactIdMatch){  // key is nil and incoming Contact don't match!
        return YES;
    }
    else{
        return NO; // group match or incoming contact match then no refresh
    }
    
}

//-(void)checkUserBlockStatus       USER BLOCK COMMENTED TILL NEXT RELEASE
//{
//    ALContactDBService *dbService = [ALContactDBService new];
//    ALContact *contact = [dbService loadContactByKey:@"userId" value:self.contactIds];
//    if(contact.block)
//    {
//        [self freezeView];
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"OOPS !!!"
//                                                        message: @"THIS USER IS BLOCKED BY YOU"
//                                                       delegate: nil
//                                              cancelButtonTitle: @"OK"
//                                              otherButtonTitles: nil];
//        alert.delegate = self;
//        [alert show];
//        
//    }
//}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == [alertView cancelButtonIndex])
//    {
//        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
//        for (UIViewController *aViewController in allViewControllers)
//        {
//            if ([aViewController isKindOfClass:[ALMessagesViewController class]])
//            {
//                [self.navigationController popToViewController:aViewController animated:YES];
//            }
//        }
//    }
//   
//}

-(void)checkIfChannelLeft{
    ALChannelService * alChannelService  = [[ALChannelService alloc] init];
    if([alChannelService isChannelLeft:self.channelKey])
    {
        [self freezeView];
        ALNotificationView * notification = [[ALNotificationView alloc] init];
        [notification showGroupLeftMessage];
    }

}

-(void)freezeView
{
    [self.sendMessageTextView setHidden:YES];
    [self.navigationItem.titleView setUserInteractionEnabled:NO];
    [self.sendButton setUserInteractionEnabled:NO];
    [self.attachmentOutlet setUserInteractionEnabled:NO];

}
//------------------------------------------------------------------------------------------------------------------
#pragma mark - SetUp/Theming
//------------------------------------------------------------------------------------------------------------------

-(void)initialSetUp {
    self.rp = 200;
    self.startIndex = 0;
    self.alMessageWrapper = [[ALMessageArrayWrapper alloc] init];
    self.mImagePicker = [[UIImagePickerController alloc] init];
    self.mImagePicker.delegate = self;
    
    [self.mTableView registerClass:[ALChatCell class] forCellReuseIdentifier:@"ChatCell"];
    [self.mTableView registerClass:[ALImageCell class] forCellReuseIdentifier:@"ImageCell"];
    [self.mTableView registerClass:[ALAudioCell class] forCellReuseIdentifier:@"AudioCell"];
    [self.mTableView registerClass:[ALVideoCell class] forCellReuseIdentifier:@"VideoCell"];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.frame = CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width, 216);
    
    defaultTableRect = self.mTableView.frame;
    [self setTitle];
    
}
-(void)setupPickerView{
    self.pickerConvIdsArray = [[NSMutableArray alloc] init];
    ALConversationService * alconversationService = [[ALConversationService alloc]init];
    NSMutableArray * conversationList ;
    
    if(self.channelKey){
        conversationList = [NSMutableArray arrayWithArray:[alconversationService
                                                    getConversationProxyListForChannelKey:self.channelKey]];
    }
    else{
        conversationList = [NSMutableArray arrayWithArray:[alconversationService
                                                    getConversationProxyListForUserID:self.contactIds]];
    }
   
    self.conversationTitleList = [[NSMutableArray alloc] init];
    for(ALConversationProxy * conversation in conversationList){
        ALTopicDetail * topicDetail  = conversation.getTopicDetail;
        if(conversation.getTopicDetail){
        [self.conversationTitleList addObject:topicDetail.title];
        [self.pickerConvIdsArray addObject:conversation.Id];
        }
    }
   
    [self.pickerView setHidden:YES];
    self.pickerDataSourceArray = [NSArray arrayWithArray:self.conversationTitleList];
    
}
-(void) setTitle {
    if(self.displayName){
        ALContactService * contactService = [[ALContactService alloc] init];
        self.alContact = [contactService loadOrAddContactByKeyWithDisplayName:self.contactIds value: self.displayName];
        
    }else{
        ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
        self.alContact = [theDBHandler loadContactByKey:@"userId" value: self.contactIds];
        
    }
    
    UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleLabelButton.frame = CGRectMake(0, 0, 70, 44);
    [titleLabelButton addTarget:self action:@selector(didTapTitleView:) forControlEvents:UIControlEventTouchUpInside];
    [titleLabelButton setTitle:[self.alContact displayName] forState:UIControlStateNormal];
    titleLabelButton.userInteractionEnabled=NO;
    if([self isGroup])
    {
        ALChannelService *channelService = [[ALChannelService alloc] init];
        [titleLabelButton setTitle:[channelService getChannelName:self.channelKey] forState:UIControlStateNormal];
        titleLabelButton.userInteractionEnabled=YES;
    }
    self.navigationItem.titleView = titleLabelButton;
    ALUserDetail *userDetail = [[ALUserDetail alloc] init];
    userDetail.connected = self.alContact.connected;
    userDetail.userId = self.alContact.userId;
    userDetail.lastSeenAtTime = self.alContact.lastSeenAt;
    [self updateLastSeenAtStatus:userDetail];
}

-(void)didTapTitleView:(id)sender{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALGroupDetailViewController.class]];
    ALGroupDetailViewController *groupDetailViewController = (ALGroupDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ALGroupDetailViewController"];
    groupDetailViewController.channelKeyID=self.channelKey;
    groupDetailViewController.lastSeenMembersArray = [NSArray arrayWithArray:[self getLastSeenForGroupDetails]];
    [self.navigationController pushViewController:groupDetailViewController animated:YES];
    
    
}
-(void)fetchMessageFromDB {
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate* predicate1;
    if(self.conversationId){
        predicate1 = [NSPredicate predicateWithFormat:@"conversationId = %d", [self.conversationId intValue]];
        
    }else if(self.isGroup){
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %d", [self.channelKey intValue]];
    }else{
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil", self.contactIds];
    }
    
    NSPredicate* compoundPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1]];
    [theRequest setPredicate:compoundPredicate];
    
    self.mTotalCount = [theDbHandler.managedObjectContext countForFetchRequest:theRequest error:nil];
    
}

//This is just a test method
-(void)refreshTable:(id)sender {
    
    NSLog(@"calling refresh from server....");
    
    //TODO: get the user name, devicekey String and make server call...
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = CGPointMake(160, 160);
    loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    [ self fetchAndRefresh:YES ];
    [loadingIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma  mark - ALMapViewController Delegate Methods -
-(void)googleImage:(UIImage*)staticImage withURL:(NSString *)googleMapUrl{
    
    if (googleMapUrl.length != 0) {
    
        ALMessage * theMessage = [self getMessageToPost];
        theMessage.contentType=2;
        theMessage.message=googleMapUrl;
        
        ALFileMetaInfo *info = [ALFileMetaInfo new];
        info.contentType = @"location";
        theMessage.fileMeta=info;
        
        
        [self.alMessageWrapper addALMessageToMessageArray:theMessage];
        [self.mTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [super scrollTableViewToBottomWithAnimation:YES];
        });
        // save message to db
        [self.sendMessageTextView setText:nil];
        self.mTotalCount = self.mTotalCount+1;
        self.startIndex = self.startIndex + 1;
        [self sendMessage:theMessage];
        
    }
    else{
        NSLog(@"Google Map Length = ZERO");
        
        NSString *alertMsg = @"Unable to fetch current location. Try Again!!!";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Current Location" message:alertMsg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        
        [alertView show];
    }
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - UIMenuController Actions
//------------------------------------------------------------------------------------------------------------------
//-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
//    return (action == @selector(copy:) || action == @selector(deleteAction:));
//}

// Default copy method
//- (void)copy:(id)sender {
//
//    NSLog(@"Copy in ALChatViewController, messageId: %@", messageId);
//    ALMessage * alMessage =  [self getMessageFromViewList:@"key" withValue:messageId ];
//
//    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
//    /*UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:self.indexPathofSelection];*/
//    if(alMessage.message!=NULL){
//
//    //[pasteBoard setString:cell.textLabel.text];
//    [pasteBoard setString:alMessage.message];
//    }
//    else{
//    [pasteBoard setString:@""];
//    }
//}
//
//
//-(void)deleteAction:(id)sender{
//    NSLog(@"Delete Menu item Pressed in AlChatViewController");
//    [ALMessageService deleteMessage:messageId andContactId:self.contactIds withCompletion:^(NSString* string,NSError* error){
//        if(!error ){
//            NSLog(@"No Error");
//        }
//        else{
//            NSLog(@"some error");
//        }
//    }];
//
//    [self.mMessageListArray removeObjectAtIndex:self.indexPathofSelection.row];
//    [UIView animateWithDuration:1.5 animations:^{
//        //      [self loadChatView];
//        [self.mTableView reloadData];
//    }];
//
//
//
//}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - IBActions
//------------------------------------------------------------------------------------------------------------------

-(void) postMessage
{
    if (self.sendMessageTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                                  @"Empty" message:@"Did you forget to type the message?" delegate:self
                                                  cancelButtonTitle:nil otherButtonTitles:@"Yes, Let me add something", nil];
        [alertView show];
        return;
    }
    ALMessage * theMessage = [self getMessageToPost];
    [self.alMessageWrapper addALMessageToMessageArray:theMessage];
    [self.mTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super scrollTableViewToBottomWithAnimation:YES];
    });
    // save message to db
    [self.sendMessageTextView setText:nil];
    self.mTotalCount = self.mTotalCount + 1;
    self.startIndex = self.startIndex + 1;
    [self sendMessage:theMessage];
    if(typingStat == YES && !self.channelKey)
    {
        typingStat = NO;
        [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - TableView Datasource
//------------------------------------------------------------------------------------------------------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.alMessageWrapper getUpdatedMessageArray].count > 0 ? [self.alMessageWrapper getUpdatedMessageArray].count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALMessage * theMessage = [self.alMessageWrapper getUpdatedMessageArray][indexPath.row];
    
    if(theMessage.contentType == (short)ALMESSAGE_CONTENT_LOCATION)
    {
        ALImageCell *theCell = (ALImageCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        [theCell populateCell:theMessage viewSize:self.view.frame.size];
        [self.view layoutIfNeeded];
        return theCell;
        
    }
    else if ([theMessage.fileMeta.contentType hasPrefix:@"video"])
    {
        ALVideoCell *theCell = (ALVideoCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoCell"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        [theCell populateCell:theMessage viewSize:self.view.frame.size];
        [self.view layoutIfNeeded];
        return theCell;
    }
    else if ([theMessage.fileMeta.contentType hasPrefix:@"audio"])
    {
        ALAudioCell *theCell = (ALAudioCell *)[tableView dequeueReusableCellWithIdentifier:@"AudioCell"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        [theCell populateCell:theMessage viewSize:self.view.frame.size];
        [self.view layoutIfNeeded];
        return theCell;
    }
    else if (theMessage.fileMeta.thumbnailUrl == nil ) { // textCell
        
        ALChatCell *theCell = (ALChatCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        [theCell populateCell:theMessage viewSize:self.view.frame.size];
        return theCell;
        
    }
    else
    {
        ALImageCell *theCell = (ALImageCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        theCell.backgroundColor = [UIColor clearColor];
        [theCell populateCell:theMessage viewSize:self.view.frame.size];
        [self.view layoutIfNeeded];
        return theCell;
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//------------------------------------------------------------------------------------------------------------------
#pragma mark - TableView Delegate
//------------------------------------------------------------------------------------------------------------------

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sendMessageTextView resignFirstResponder];
    ALMessage *msgCell = self.alMessageWrapper.messageArray[indexPath.row];
    if([msgCell.type isEqualToString:@"100"])
    {
        return  nil;
    }
    else
    {
        return indexPath;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALMessage * theMessage = [self.alMessageWrapper getUpdatedMessageArray][indexPath.row];
    
    if((theMessage.message.length > 0) && (theMessage.fileMeta.thumbnailUrl != nil))
    {
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width - 115 font:@"Helvetica-Bold" fontSize:15];
        return theTextSize.height + self.view.frame.size.width - 30;
    }
    else if(theMessage.contentType == (short)ALMESSAGE_CONTENT_LOCATION)
    {
       return self.view.frame.size.width - 150;
    }
    else if([theMessage.type isEqualToString:@"100"])
    {
        return 30;
    }
    else if ([theMessage.fileMeta.contentType hasPrefix:@"video"])
    {
        return self.view.frame.size.width - 110 + 40;
    }
    else if ([theMessage.fileMeta.contentType hasPrefix:@"audio"])
    {
        return 120;
    }
    else if (theMessage.fileMeta.thumbnailUrl == nil)
    {
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width - 115 font:@"Helvetica-Bold" fontSize:15];
        int extraSpace = 50 ;
        return theTextSize.height + 21 + extraSpace;
    }
    else
    {
        return self.view.frame.size.width - 110 + 40;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALMessage *msgCell = self.alMessageWrapper.messageArray[indexPath.row];
    if([msgCell.type isEqualToString:@"100"])
    {
        return  NO;
    }
    else
    {
        return YES;
    }
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
    if (action == @selector(copy:)) {
        NSLog(@"COPY");
        [self copy:NULL];
    }
    if (action == @selector(deleteAction:)) {
        NSLog(@"DELETE ACTION");
    }
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

#pragma mark - Display Header/Footer View
//======================================
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // For Header's Text View
    
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.contentView.backgroundColor = [UIColor lightGrayColor];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.conversationId ? self.getHeaderView.frame.size.height : 0;
}

#pragma mark -  Header View
//===========================
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return self.getHeaderView;
}


-(UIView *)getHeaderView{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 84)];
    ALConversationService * alconversationService = [[ALConversationService alloc]init];
    ALConversationProxy *alConversationProxy = [alconversationService getConversationByKey:self.conversationId];
    ALTopicDetail * topicDetail  = alConversationProxy.getTopicDetail;
    
    // Image View ....
    UIImageView *imageView = [[UIImageView alloc] init];
    NSURL * url = [NSURL URLWithString:topicDetail.link];
    [imageView sd_setImageWithURL:url];
    
    imageView.frame = CGRectMake(5, 27, 50, 50);
    imageView.backgroundColor = [UIColor blackColor];
    [view addSubview:imageView];
    
    UILabel * topLeft = [[UILabel alloc] init];
    topLeft.text =topicDetail.title;
    topLeft.frame = CGRectMake(imageView.frame.size.width + 10,
                               25,
                               (view.frame.size.width-imageView.frame.size.width)/2,
                               50);
    
    UILabel * bottomLeft = [[UILabel alloc] init];
    bottomLeft.text =topicDetail.subtitle;
    bottomLeft.frame = CGRectMake(imageView.frame.size.width + 10,
                                  58,
                                  (view.frame.size.width-imageView.frame.size.width)/2,
                                  50);
    bottomLeft.numberOfLines = 1;
    bottomLeft.preferredMaxLayoutWidth = 8;
    bottomLeft.adjustsFontSizeToFitWidth = YES;
    
    UILabel* topRight = [[UILabel alloc] init];
    topRight.text = [NSString stringWithFormat:@"%@:%@",topicDetail.key1,topicDetail.value1];
    topRight.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - topLeft.frame.size.width)+ 10,
                                25,
                                [UIScreen mainScreen].bounds.size.width - topLeft.frame.size.width,
                                50);
    
    
    UILabel* bottomRight = [[UILabel alloc] init];
    bottomRight.text = [NSString stringWithFormat:@"%@:%@",topicDetail.key2,topicDetail.value2];
    bottomRight.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - bottomLeft.frame.size.width)+ 10,
                                   58,
                                   [UIScreen mainScreen].bounds.size.width - bottomLeft.frame.size.width,
                                   50);
    
   [self setLabelViews:@[topLeft,bottomLeft,topRight,bottomRight] onView:view];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showConversationPicker:)];
    [view addGestureRecognizer:singleFingerTap];

    return view;
}

-(void)setLabelViews:(NSArray*)labelArray onView:(UIView*)view{
    
    view.backgroundColor=[ALApplozicSettings getColorForNavigation];
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    view.layer.shadowRadius = 3.0f;
    view.layer.shadowOpacity = 1.0f;
    
    for (UILabel * label in labelArray) {
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Helvetica" size:11.0];
        [self resizeLabels:label];
        [view addSubview:label];
    }

}
-(void)resizeLabels:(UILabel*)label{
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
}

#pragma mark - Picker View Delegate Datasource
//=============================================

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerDataSourceArray.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickerDataSourceArray[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (component){
        case 0:
            return 200.0f;
        case 1:
            return 20.0f;
    }
    return 0;
}


#pragma mark - PickerView Display Method
//======================================
-(void)showConversationPicker:(UITapGestureRecognizer *)recognizer{
    isPickerOpen = YES;
    NSNumber *iD= self.conversationId;
    NSInteger anIndex = 0;
    
    if(self.pickerConvIdsArray.count>0){
     anIndex = [self.pickerConvIdsArray indexOfObject:iD];
    }
    if(NSNotFound == anIndex) {
        NSLog(@"PickerView Index not found %ld",(long)anIndex);
    }
    
    [self.pickerView selectRow:anIndex inComponent:0 animated:NO];

    [self setRightNavButtonToDone];
    
    
    [self.sendMessageTextView endEditing:YES];
    
    dispatch_queue_t queue = dispatch_queue_create("animateAndMask", NULL);
    
    dispatch_sync(queue, ^{
        
        [UIView animateWithDuration:0.4 animations:^{
           
            self.tableViewTop2Constraint.constant = 44 + self.pickerView.frame.size.height;
            self.mTableView.frame = CGRectMake(0,self.pickerView.frame.size.height,
                                               defaultTableRect.size.height,
                                               [UIScreen mainScreen].bounds.size.width);
            [self.view layoutIfNeeded];
            [self.pickerView setHidden:NO];

        }];
        [self disableRestView];
    });
}

#pragma mark - PickerView Display Navigation Buttons update Methods
//=================================================================
-(void)setRightNavButtonToDone{
    UIBarButtonItem *donePickerSelectionButton = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Done"
                                                  style:UIBarButtonItemStylePlain
                                                  target:self action:@selector(donePicking:)];
    
    self.navigationItem.rightBarButtonItem = donePickerSelectionButton;
}

-(void)setRightNavButtonToRefresh{
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTable:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
}


#pragma mark - Picker View Done and View Update Methods
//=====================================================
-(void)donePicking:(id)sender{
    
    self.tableViewBottomToAttachment.constant = 0;
    [UIView animateWithDuration:0.4 animations:^{
        
        
        self.mTableView.frame = CGRectMake(0,defaultTableRect.origin.y,
                                           defaultTableRect.size.height,
                                           [UIScreen mainScreen].bounds.size.width);
        
        self.tableViewTop2Constraint.constant = 44;
        self.mTableView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.2];
        [self.view layoutIfNeeded];
        [self.pickerView setHidden:YES];
    }];
    
    [self setRightNavButtonToRefresh];
    
    [self updateContextInView];
    isPickerOpen = NO;
}

//========= Update Table with new data according to context============
-(void)updateContextInView{
    
    [self.mTableView setUserInteractionEnabled:YES];
    [self.sendMessageTextView setHidden:NO];

    NSInteger pickerRowSelected = (long)[self.pickerView selectedRowInComponent:0];
    
    if(self.conversationId != self.pickerConvIdsArray[pickerRowSelected] &&  self.pickerConvIdsArray[pickerRowSelected] != nil ){
        
        self.conversationId = self.pickerConvIdsArray[pickerRowSelected];
       
        [[self.alMessageWrapper messageArray] removeAllObjects];
        
        if (![ALUserDefaultsHandler isServerCallDoneForMSGList:[self.conversationId stringValue]]) {
           [self processLoadEarlierMessages:YES];
        }
        else{
            [self reloadView];
        }
        
    }
    
}

//============== Masks background when picker shown ===================
-(void)disableRestView{
    [self.mTableView setUserInteractionEnabled:NO];
    [self.sendMessageTextView setHidden:YES];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Helper Method
//------------------------------------------------------------------------------------------------------------------

-(ALMessage *) getMessageToPost
{
    ALMessage * theMessage = [ALMessage new];
    
    theMessage.type = @"5";
    theMessage.contactIds = self.contactIds;//1
    theMessage.to = self.contactIds;//2
    theMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString ];
    theMessage.message = self.sendMessageTextView.text;//3
    theMessage.sendToDevice = NO;
    theMessage.sent = NO;
    theMessage.shared = NO;
    theMessage.fileMeta = nil;
    theMessage.read = NO;
    theMessage.storeOnDevice = NO;
    theMessage.key = [[NSUUID UUID] UUIDString];
    theMessage.delivered = NO;
    theMessage.fileMetaKey = nil;//4
    theMessage.contentType = 0; //TO-DO chnge after...
    theMessage.groupId = self.channelKey;
    theMessage.conversationId  = self.conversationId;
    return theMessage;
}

-(ALFileMetaInfo *) getFileMetaInfo
{
    ALFileMetaInfo *info = [ALFileMetaInfo new];
    
    info.blobKey = nil;
    info.contentType = @"";
    info.createdAtTime = nil;
    info.key = nil;
    info.name = @"";
    info.size = @"";
    info.userKey = @"";
    info.thumbnailUrl = @"";
    info.progressValue = 0;
    
    return info;
}

#pragma mark helper methods

-(void) loadChatView
{
    
    [self setTitle];
    BOOL isLoadEarlierTapped = [self.alMessageWrapper getUpdatedMessageArray].count == 0 ? NO : YES ;
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setFetchLimit:self.rp];
    NSPredicate* predicate1;
    if(self.conversationId){
        predicate1 = [NSPredicate predicateWithFormat:@"conversationId = %d", [self.conversationId intValue]];

    }else if(self.isGroup){
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %d", [self.channelKey intValue]];
    }else{
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil", self.contactIds];
    }

    self.mTotalCount = [theDbHandler.managedObjectContext countForFetchRequest:theRequest error:nil];
    
    NSPredicate* predicate2=[NSPredicate predicateWithFormat:@"deletedFlag == NO"];
    NSPredicate* compoundPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
    [theRequest setPredicate:compoundPredicate];
    [theRequest setFetchOffset:self.startIndex];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    
    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (DB_Message * theEntity in theArray) {
        ALMessage * theMessage = [messageDBService createMessageEntity:theEntity];
        [tempArray insertObject:theMessage atIndex:0];
        //[self.mMessageListArrayKeyStrings insertObject:theMessage.key atIndex:0];
    }
    
    [self.alMessageWrapper addObjectToMessageArray:tempArray];
    [self.mTableView reloadData];
    
    
    if (isLoadEarlierTapped) {
        if ((theArray != nil && theArray.count < self.rp )|| [self.alMessageWrapper getUpdatedMessageArray].count == self.mTotalCount) {
//            self.mTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        self.startIndex = self.startIndex + theArray.count;
        [self.mTableView reloadData];
        if (theArray.count != 0) {
            CGRect theFrame = [self.mTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:theArray.count-1 inSection:0]];
            [self.mTableView setContentOffset:CGPointMake(0, theFrame.origin.y-60)];
        }
    }
    else
    {
        
        if (theArray.count < self.rp || [self.alMessageWrapper getUpdatedMessageArray].count == self.mTotalCount) {
//            self.mTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        else
        {
//            self.mTableView.tableHeaderView = self.mTableHeaderView;
        }
        self.startIndex = theArray.count;
        
        /*if (self.mMessageListArray.count != 0) {
         CGRect theFrame = [self.mTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:theArray.count-1 inSection:0]];
         [self.mTableView setContentOffset:CGPointMake(0, theFrame.origin.y)];
         }*/
        dispatch_async(dispatch_get_main_queue(), ^{
            [super scrollTableViewToBottomWithAnimation:YES];
        });
        
    }
    
    self.refresh = YES;
}

#pragma mark IBActions

-(void) attachmentAction
{
    // check os , show sheet or action controller
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 ) { // ios 7 and previous
        [self showActionSheet];
    }
    else // ios 8
    {
        [self showActionAlert];
    }
}

#pragma mark chatCellDelegate

-(void) deleteMessageFromView:(ALMessage *) message {
    
    NSLog(@"  deleteMessageFromView in controller...:: ");
    [self.alMessageWrapper removeALMessageFromMessageArray:message];
    
    [UIView animateWithDuration:1.5 animations:^{
        [self.mTableView reloadData];
    }];
}

#pragma mark chatCellImageDelegate

-(void)downloadRetryButtonActionDelegate:(int)index andMessage:(ALMessage *)message
{
     ALMediaBaseCell *imageCell = (ALMediaBaseCell *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    imageCell.progresLabel.alpha = 1;
    imageCell.mMessage.fileMeta.progressValue = 0;
    imageCell.mDowloadRetryButton.alpha = 0;
    message.inProgress = YES;
    
    NSMutableArray * theCurrentConnectionsArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
    NSArray * theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.key]];
    if (theFiletredArray.count == 0){
        message.isUploadFailed = NO;
        message.inProgress=YES;
        
        NSError *error =nil;
        DB_Message *dbMessage = (DB_Message*)[dbService getMeesageById:message.msgDBObjectId error:&error];
        dbMessage.inProgress = [NSNumber numberWithBool:YES];
        dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
        
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        if ([message.type isEqualToString:@"5"]&& !message.fileMeta.key) { // upload
            [self uploadImage:message];
            
        }else { //download
            [ALMessageService processImageDownloadforMessage:message withdelegate:self];
            
        }
        NSLog(@"starting thread for..%@", message.key);
    }else{
        NSLog(@"connection already present do nothing###");
    }
    
}

-(void)stopDownloadForIndex:(int)index andMessage:(ALMessage *)message {
    NSLog(@"Called get image stopDownloadForIndex stopDownloadForIndex ####");
    
    ALMediaBaseCell *imageCell = (ALMediaBaseCell *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    imageCell.progresLabel.alpha = 0;
    imageCell.mDowloadRetryButton.alpha = 1;
    message.inProgress = NO;
    [self handleErrorStatus:message];
    [self releaseConnection:message.key];
    
}

-(void)showFullScreen:(UIViewController*)uiController{
    [self presentViewController:uiController animated:YES completion:nil];
    
    
}

#pragma mark connection delegates

//Progress
-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data
{
    [connection.mData appendData:data];
    if ([connection.connectionType isEqualToString:@"Image Posting"]) {
        NSLog(@" file posting done");
        return;
    }
    
    ALMediaBaseCell*  cell=  [self getCell:connection.keystring];
    cell.progresLabel.endDegree = [self bytesConvertsToDegree:[cell.mMessage.fileMeta.size floatValue] comingBytes:(CGFloat)connection.mData.length];;
    
}

-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    ALMediaBaseCell * cell = [self getCell:connection.keystring];
     cell.progresLabel.endDegree = [self bytesConvertsToDegree:totalBytesExpectedToWrite comingBytes:totalBytesWritten];
}

//Finishing

-(void)connectionDidFinishLoading:(ALConnection *)connection {
    
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    dbService = [[ALMessageDBService alloc]init];
    
    if ([connection.connectionType isEqualToString:@"Image Posting"]) {
        ALMessage * message = [self getMessageFromViewList:@"key" withValue:connection.keystring];
        //get it fromDB ...we can move it to thread as nothing to show to user
        if(!message){
            DB_Message * dbMessage = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
            message = [ dbService createMessageEntity:dbMessage];
        }
        NSError * theJsonError = nil;
        NSDictionary *theJson = [NSJSONSerialization JSONObjectWithData:connection.mData options:NSJSONReadingMutableLeaves error:&theJsonError];
        NSDictionary *fileInfo = [theJson objectForKey:@"fileMeta"];
        [message.fileMeta populate:fileInfo ];
        ALMessage * almessage =  [ALMessageService processFileUploadSucess:message];
        
        [self sendMessage:almessage ];
    }else {
        
        DB_Message * messageEntity = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
        
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *componentsArray = [messageEntity.fileMetaInfo.name componentsSeparatedByString:@"."];
        NSString *fileExtension = [componentsArray lastObject];
        NSString * filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_local.%@",connection.keystring,fileExtension]];
        [connection.mData writeToFile:filePath atomically:YES];
        // update db
        messageEntity.inProgress = [NSNumber numberWithBool:NO];
        messageEntity.isUploadFailed=[NSNumber numberWithBool:NO];
        messageEntity.filePath = [NSString stringWithFormat:@"%@_local.%@",connection.keystring,fileExtension];
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        ALMessage * message = [self getMessageFromViewList:@"key" withValue:connection.keystring];
        if(message){
            message.isUploadFailed = NO;
            message.inProgress=NO;
            message.imageFilePath =  messageEntity.filePath;
            [self.mTableView reloadData];
        }
        
    }
    
}

//Error
-(void)connection:(ALConnection *)connection didFailWithError:(NSError *)error
{
    //Tag should be something else...
    
    ALMediaBaseCell * imageCell=  [self getCell:connection.keystring];
    imageCell.progresLabel.alpha = 0;
    imageCell.mDowloadRetryButton.alpha = 1;
    [self handleErrorStatus:imageCell.mMessage];
    NSLog(@"didFailWithError ::: %@",error);
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
}

//===============================================
#pragma mark IMAGE PICKER DELEGATES
//===============================================

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image getCompressedImageLessThanSize:5];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALAttachmentController *obtext;

    if(image)
    {
        obtext = [storyboard instantiateViewControllerWithIdentifier:@"imageandtext"];
        [obtext setImagedocument:image];
        [self.navigationController pushViewController:obtext animated:YES];
        obtext.imagecontrollerDelegate = self;
    }
    
    // VIDEO ATTACHMENT
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeMovie) != 0;

    if(isMovie)
    {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        NSString *videoFilePath = [ALImagePickerHandler saveVideoToDocDirectory:videoURL];
        short contentType = ALMESSAGE_CONTENT_ATTACHMENT;
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            contentType = ALMESSAGE_CONTENT_CAMERA_RECORDING;
        }
        [self processAttachment:videoFilePath andMessageText:@"" andContentType:contentType];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)check:(UIImage *)imageFile andText:(NSString *)textwithimage
{
    // save image to doc
    NSString * filePath = [ALImagePickerHandler saveImageToDocDirectory:imageFile];
    [self processAttachment:filePath andMessageText:textwithimage andContentType:ALMESSAGE_CONTENT_ATTACHMENT];
}

-(void)processAttachment:(NSString *)filePath andMessageText:(NSString *)textwithimage andContentType:(short)contentype
{
    // create message object
    ALMessage * theMessage = [self getMessageToPost];
    theMessage.contentType = contentype;
    theMessage.fileMeta = [self getFileMetaInfo];
    theMessage.message = textwithimage;
    theMessage.imageFilePath = filePath.lastPathComponent;
    theMessage.fileMeta.name = [NSString stringWithFormat:@"%@-5-%@",self.contactIds, filePath.lastPathComponent];
    
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    
    theMessage.fileMeta.contentType = mimeType;
    
    NSData *imageSize = [NSData dataWithContentsOfFile:filePath];
    theMessage.fileMeta.size = [NSString stringWithFormat:@"%lu",(unsigned long)imageSize.length];
    //theMessage.fileMetas.thumbnailUrl = filePath.lastPathComponent;
    
    // save msg to db
    [self.alMessageWrapper addALMessageToMessageArray:theMessage];
    
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
    DB_Message * theMessageEntity = [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    theMessage.msgDBObjectId = [theMessageEntity objectID];
    
    [self.mTableView reloadData];
    [self scrollTableViewToBottomWithAnimation:NO];
    [self uploadImage:theMessage];
}

-(void)uploadImage:(ALMessage *)theMessage
{
    if (theMessage.fileMeta && [theMessage.type isEqualToString:@"5"])
    {
        NSDictionary * userInfo = [theMessage dictionary];
        [self.sendMessageTextView setText:nil];
        self.mTotalCount = self.mTotalCount+1;
        self.startIndex = self.startIndex + 1;
        
        ALMediaBaseCell* imageCell = [self getCell:theMessage.key];
        
        if(!imageCell)
        {
            NSLog(@" not able to find the image cell for upload....");
            return;
        }
        
        imageCell.progresLabel.alpha = 1;
        imageCell.mMessage.fileMeta.progressValue = 0;
        imageCell.mDowloadRetryButton.alpha = 0;
        imageCell.mMessage.inProgress = YES;
        if([theMessage.fileMeta.contentType hasPrefix:@"audio"])
        {
           [imageCell hidePlayButtonOnUploading];
        }
        NSError *error=nil;
        ALMessageDBService  * dbService = [[ALMessageDBService alloc] init];
        DB_Message *dbMessage = (DB_Message*)[dbService getMeesageById:theMessage.msgDBObjectId error:&error];
        dbMessage.inProgress = [NSNumber numberWithBool:YES];
        dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        
        // post image
        ALMessageClientService * clientService  = [[ALMessageClientService alloc]init];
        [clientService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
            
            if (error)
            {
                NSLog(@"%@",error);
                imageCell.progresLabel.alpha = 0;
                imageCell.mDowloadRetryButton.alpha = 1;
                [self handleErrorStatus:theMessage];
                return ;
            }
            [ALMessageService proessUploadImageForMessage:theMessage databaseObj:dbMessage.fileMetaInfo uploadURL:message  withdelegate:self];
            
        }];
    }
}

//===============================================
#pragma AUDIO DELEGATE
//===============================================

-(void)audioAttachment:(NSString *)audioFilePath
{
    [self processAttachment:audioFilePath andMessageText:@"" andContentType:ALMESSAGE_CONTENT_AUDIO];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - ActionsSheet Methods
//------------------------------------------------------------------------------------------------------------------

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"photo library"])
        [self openGallery];
    
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"take photo"])
        [self openCamera];
}

-(void) showActionSheet
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"current location",@"take photo",@"photo library", nil];
    
    [actionSheet showInView:self.view];
}

-(void) showActionAlert
{
    UIAlertController * theController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [theController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [theController addAction:[UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCamera];
    }]];
    [theController addAction:[UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openGallery];
        
    }]];
    [theController addAction:[UIAlertAction actionWithTitle:@"Current location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
        ALMapViewController *vc = (ALMapViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareLoactionViewTag"];
        vc.controllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }]];
    
    [theController addAction:[UIAlertAction actionWithTitle:@"Send Audio" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
        ALAudioAttachmentViewController *audioViewController = (ALAudioAttachmentViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AudioAttachment"];
        audioViewController.audioAttchmentDelegate = self;
        
        [self.navigationController pushViewController:audioViewController animated:YES];
        
    }]];
    
    [theController addAction:[UIAlertAction actionWithTitle:@"Send Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            self.mImagePicker.allowsEditing = YES;
            self.mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
            
            [self presentViewController:self.mImagePicker animated:YES completion:NULL];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"OOPS !!!"
                                                            message: @"Camera is not Available !!!"
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        
    }]];
    
    [theController addAction:[UIAlertAction actionWithTitle:@"Video Albums" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        [self presentViewController:self.mImagePicker animated:YES completion:nil];
        
    }]];
    
    [self presentViewController:theController animated:YES completion:nil];
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"You picked : %@",mediaItemCollection);
    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        [self presentViewController:_mImagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Camera is not available in device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) openGallery
{
    _mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self presentViewController:_mImagePicker animated:YES completion:nil];
}



-(void) handleErrorStatus:(ALMessage *) message{
    message.inProgress=NO;
    message.isUploadFailed=YES;
    NSError *error=nil;
    dbService = [[ALMessageDBService alloc] init];
    DB_Message *dbMessage =(DB_Message*)[dbService getMeesageById:message.msgDBObjectId error:&error];
    
    dbMessage.inProgress = [NSNumber numberWithBool:NO];
    dbMessage.isUploadFailed = [NSNumber numberWithBool:YES];
    dbMessage.sentToServer= [NSNumber numberWithBool:NO];;
    
    [[ALDBHandler sharedInstance].managedObjectContext save:nil];
    
}

-(void) releaseConnection:(NSString *) key
{
    NSMutableArray * theConnectionArray =  [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
    NSArray * filteredArray = [theConnectionArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@",key]];
    if(filteredArray.count >0 ){
        ALConnection * connection = [filteredArray objectAtIndex:0];
        [connection cancel];
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    }else{
        NSLog(@"connection is not found");
    }
    
}

-(ALMediaBaseCell *) getCell:(NSString *)key{
    
    int index = (int)[[self.alMessageWrapper getUpdatedMessageArray] indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop)
                     {
                         ALMessage *message = (ALMessage*)element;
                         
                         if( [ message.key isEqualToString:key ])
                         {
                             *stop = YES;
                             return YES;
                         }
                         return NO;
                     }];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    ALMediaBaseCell *cell = (ALMediaBaseCell *)[self.mTableView cellForRowAtIndexPath:path];
    
    return cell;
}

-(void)sendMessage:(ALMessage* )theMessage{
    
    [ALMessageService sendMessages:theMessage withCompletion:^(NSString *message, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            [self handleErrorStatus:theMessage];
            return;
        }
        [self.mTableView reloadData];
        [self setRefreshMainView:TRUE];
    }];
    
}

-(CGFloat)bytesConvertsToDegree:(CGFloat)totalBytesExpectedToWrite comingBytes:(CGFloat)totalBytesWritten {
    CGFloat  totalBytes = totalBytesExpectedToWrite;
    CGFloat writtenBytes = totalBytesWritten;
    CGFloat divergence = totalBytes/360;
    CGFloat degree = writtenBytes/divergence;
    return degree;
}

- (ALMessage* )getMessageFromViewList:(NSString *)key withValue:(NSString*)value{
    
    NSArray * filteredArray = [[self.alMessageWrapper getUpdatedMessageArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",key,value]];
    if (filteredArray.count > 0) {
        return filteredArray[0];
    }
    
    return nil;
}

-(void)fetchAndRefresh{
    [self fetchAndRefresh:NO];
}

-(void)fetchAndRefresh:(BOOL)flag{
    NSString *deviceKeyString =[ALUserDefaultsHandler getDeviceKeyString ] ;
    
    [ ALMessageService getLatestMessageForUser: deviceKeyString withCompletion:^(NSMutableArray  *messageList, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            return ;
        } else {
            if (messageList.count > 0 ){
                
                if(flag)
                {
                    [self processMarkRead];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [super scrollTableViewToBottomWithAnimation:YES];
                [self setTitle];
            });
            NSLog(@"FETCH AND REFRESH METHOD");
        }
    }];
}

-(void) updateDeliveryReportForConversation {
    NSArray * filteredArray = [[self.alMessageWrapper getUpdatedMessageArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"delivered = %@",@(NO)]];
    
    for(ALMessage * message  in  filteredArray){
        message.delivered=true;
    }
    [self.mTableView reloadData];
    //Todo: update all delivery report in all messages
}

-(void)updateDeliveryReport:(NSString*)key
{
    ALMessage * alMessage =  [self getMessageFromViewList:@"key" withValue:key ];
    if (alMessage)
    {
        alMessage.delivered=YES;
        [self.mTableView reloadData];
    }
    else
    {
        //not found
        //get message from db by key
        [ALMessageService getMessagefromKeyValuePair:@"key" andValue:key];
        //and get alMessage.msgDBObjectId
        
        ALMessage* fetchMsg = [ALMessage new];
        fetchMsg=[ALMessageService getMessagefromKeyValuePair:@"key" andValue:key];
        
        //now find in list ...
        ALMessage * alMessage2 =  [self getMessageFromViewList:@"msgDBObjectId" withValue:fetchMsg.msgDBObjectId];
        
        if (alMessage2)
        {
            alMessage2.delivered = YES;
            [self.mTableView reloadData];
        }
    }
}

-(void)individualNotificationhandler:(NSNotification *) notification
{
    NSLog(@" OUR Individual Notificationhandler ");
    [self setRefreshMainView:TRUE];
    // see if this view is visible or not...
    NSString * contactId = notification.object;
    NSDictionary *dict = notification.userInfo;
    NSNumber *updateUI = [dict valueForKey:@"updateUI"];
    NSString *alertValue = [dict valueForKey:@"alertValue"];
    NSLog(@"Notification received by Individual chat list: %@", contactId);
    
    NSArray *com=[contactId componentsSeparatedByString:@":"];
    NSString* appendToGroupId;
    if(com.count > 1)
    {
        appendToGroupId=[NSString stringWithFormat:@"%@",com[1]];
        //        appendToGroupId=[appendToGroupId componentsSeparatedByString:@":"][0];
        contactId=appendToGroupId;
    }
    else
    {
        appendToGroupId=nil;
    }
    ALMessage* alMessage  = [[ALMessage alloc] init];
    alMessage.contactIds = contactId;
    alMessage.groupId = [NSNumber numberWithInt:appendToGroupId.intValue] ;
    [self syncCall:alMessage updateUI:updateUI alertValue:alertValue];
}

-(void) syncCall:(ALMessage*)alMessage  updateUI:(NSNumber *)updateUI alertValue: (NSString *)alertValue
{
    [self setRefreshMainView:TRUE];
    bool isGroupNotification =( alMessage.groupId==nil?false :true);
    
    if (self.isGroup && isGroupNotification && [self.channelKey isEqualToNumber:alMessage.groupId] &&
        (self.conversationId.intValue == alMessage.conversationId.intValue)){
            self.conversationId = alMessage.conversationId;
            self.contactIds=alMessage.contactIds;
            [self processMarkRead];
            [self fetchAndRefresh:YES];
    }
    else if (!self.isGroup && !isGroupNotification && [self.contactIds isEqualToString:alMessage.contactIds] &&
             (self.conversationId.intValue == alMessage.conversationId.intValue)){
        //Current Same Individual Contact thread is opened..
        self.conversationId = alMessage.conversationId;
        self.channelKey=nil;
        self.contactIds=alMessage.contactIds;
        [self fetchAndRefresh:YES];
    }
    else if (![updateUI boolValue]) {
        NSLog(@"it was in background, updateUI is false");
        self.conversationId = alMessage.conversationId;
        self.channelKey=alMessage.groupId;
        self.contactIds=alMessage.contactIds;
        [self fetchAndRefresh:YES];
        [self reloadView];
        
    }
    else{
        NSLog(@"show notification as someone else thread is already opened");
        ALNotificationView * alnotification;
        alnotification =[[ALNotificationView alloc]
                         initWithAlMessage:alMessage
                         withAlertMessage:alertValue];
        [alnotification nativeNotification:self];
        if (alMessage.conversationId == self.conversationId || alMessage.conversationId == nil){
            [self fetchAndRefresh:YES];
        }
        
    }
}

-(void)updateDeliveryStatus:(NSNotification *) notification
{
    NSString * keyString = notification.object;
    [self updateDeliveryReport:keyString];
}

-(void)handleAddress:(NSDictionary *)dict{
    if([dict valueForKey:@"error"]){
        //handlen error
        return;
        
    }else {
        NSString *  address = [dict valueForKey:@"address"];
        NSString *  googleurl = [dict valueForKey:@"googleurl"];
        NSString * finalString = [address stringByAppendingString:googleurl];
        [[self sendMessageTextView] setText:finalString];
        
    }
}

-(void) reloadView{
    [[self.alMessageWrapper getUpdatedMessageArray] removeAllObjects];
    self.startIndex =0;
    [self fetchMessageFromDB];
    [self loadChatView];
    
}

-(void) reloadViewfor3rdParty{
    [[self.alMessageWrapper getUpdatedMessageArray] removeAllObjects];
    self.startIndex =0;
    [self fetchMessageFromDB];
    
}

-(void)handleNotification:(UIGestureRecognizer*)gestureRecognizer{
    
    ALNotificationView * notificationView = (ALNotificationView*)gestureRecognizer.view;
    //    ALChatViewController * ob=[[ALChatViewController alloc] init];
    
    NSLog(@" got the UI label::%@" , notificationView.contactId);
    self.contactIds = notificationView.contactId;
    [UIView animateWithDuration:0.5 animations:^{
        [self reloadView];
        
    }];
    // [self fetchAndRefresh:YES];
    [self processMarkRead];
    [UIView animateWithDuration:0.5 animations:^{
        [notificationView removeFromSuperview];
    }];
}


- (IBAction)loadEarlierButtonAction:(id)sender {
    [self processLoadEarlierMessages:false];
}

-(void)processLoadEarlierMessages:(BOOL)isScrollToBottom{
    
    NSNumber *time;
    if([self.alMessageWrapper getUpdatedMessageArray].count > 1 && [self.alMessageWrapper getUpdatedMessageArray] != NULL) {
        ALMessage * theMessage = [self.alMessageWrapper getUpdatedMessageArray][1];
        time = theMessage.createdAtTime;
    }
    else {
        NSLog(@" time### %@ ",time);
        time = NULL;
    }
    
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = self.view.center;
    loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    

    //preaper Message list request ....
    MessageListRequest *messageListRequest = [[MessageListRequest alloc]init];
    
    messageListRequest.userId=self.contactIds;
    messageListRequest.channelKey=self.channelKey;
    messageListRequest.endTimeStamp=time;
    messageListRequest.conversationId=self.conversationId;
    
    
    [ALMessageService getMessageListForUser:messageListRequest  withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray){
        [loadingIndicator stopAnimating];
        [self setupPickerView];
        [self.pickerView reloadAllComponents];
        
        if(!error ){
            self.loadEarlierAction.hidden=YES;
            if( messages.count< 50 ){
                
                if(self.conversationId){
                    [ALUserDefaultsHandler setShowLoadEarlierOption:NO forContactId:[self.conversationId stringValue]];
                }
                else{
                    NSString * IDs = (self.channelKey ? [self.channelKey stringValue] : self.contactIds);
                    [ALUserDefaultsHandler setShowLoadEarlierOption:NO forContactId:IDs];
                }
            }
            if (messages.count==0){
                
                if(self.conversationId){
                    [ALUserDefaultsHandler setShowLoadEarlierOption:NO forContactId:[self.conversationId stringValue]];
                }
                else{
                    NSString * IDs = (self.channelKey ? [self.channelKey stringValue] : self.contactIds);
                    [ALUserDefaultsHandler setShowLoadEarlierOption:NO forContactId:IDs];
                }

                return;
            }
            NSMutableArray * array = [self.alMessageWrapper getUpdatedMessageArray];
            
            if( [array firstObject ] ){
                
                ALMessage *messgae = [array firstObject ];
                
                if([ messgae.type isEqualToString:@"100"]){
                    
                    [array  removeObjectAtIndex:0];
                    
                }
                
            }
            for (ALMessage * msg in messages) {
                
                if([self.alMessageWrapper getUpdatedMessageArray].count > 0)
                {
                    ALMessage *msg1 = [[self.alMessageWrapper getUpdatedMessageArray] objectAtIndex:0];
                    if([self.alMessageWrapper checkDateOlder:msg.createdAtTime andNewer:msg1.createdAtTime])
                    {
                        ALMessage *dateCell = [self.alMessageWrapper getDatePrototype:self.alMessageWrapper.dateCellText andAlMessageObject:msg];
                        ALMessage *msg3 = [[self.alMessageWrapper getUpdatedMessageArray] objectAtIndex:0];
                        if(![msg3.type isEqualToString:@"100"])
                        {
                            [[self.alMessageWrapper getUpdatedMessageArray] insertObject:dateCell atIndex:0];
                        }
                        
                    }
                }
                [[self.alMessageWrapper getUpdatedMessageArray] insertObject:msg atIndex:0];
            }
            ALMessage * message = [array firstObject];
            if(message){
                NSString * dateTxt = [self.alMessageWrapper msgAtTop:message];
                
                ALMessage *lastMsg = [self.alMessageWrapper getDatePrototype:dateTxt andAlMessageObject:message];
                [[self.alMessageWrapper getUpdatedMessageArray] insertObject:lastMsg atIndex:0];
            }
            //self.startIndex = self.startIndex + messages.count;
            
            CGFloat oldTableViewHeight = self.mTableView.contentSize.height;
            [self.mTableView reloadData];
            
            if(isScrollToBottom){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [super scrollTableViewToBottomWithAnimation:NO];
                });
            }else{
                CGFloat newTableViewHeight = self.mTableView.contentSize.height;
                self.mTableView.contentOffset = CGPointMake(0, newTableViewHeight - oldTableViewHeight);
            }
        }
        else
        {
            NSLog(@"some error");
        }
        
    }];
    
}


-(void)serverCallForLastSeen
{
    [ALUserService userDetailServerCall:self.contactIds withCompletion:^(ALUserDetail *alUserDetail){
        if(alUserDetail)
        {
            [[[ALContactDBService alloc] init] updateUserDetail:alUserDetail];
            [self updateLastSeenAtStatus:alUserDetail];
        }
        else
        {
            NSLog(@"CHECK SERVER CALL");
        }
    }];
}

-(void)showTypingLabel:(BOOL)flag userId:(NSString *)userId
{
    if(flag && [self.alContact.userId isEqualToString: userId])
    {
        NSString *msg = self.alContact.displayName;
        [self.typingLabel setText:[msg stringByAppendingString:@" is typing..."]];
        [self.typingLabel setHidden:NO];
    }
    else
    {
        [self.typingLabel setHidden:YES];
    }
}

-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail
{
    [self setRefreshMainView:TRUE];
    
    NSString *tempString = [NSString stringWithFormat:@"%@", alUserDetail.lastSeenAtTime];
    NSCharacterSet *charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@"()  \n\""];
    tempString = [tempString stringByTrimmingCharactersInSet:charsToTrim];
    
    double value = [tempString doubleValue];
    [self.label setHidden:NO];
    
    if(self.channelKey != nil)
    {
//        ALChannelService *ob = [[ALChannelService alloc] init];
//        [self.label setText:[ob stringFromChannelUserList:self.channelKey]];
        [self.label setHidden:YES];
    }
    else if(value > 0){
        [self formatDateTime:alUserDetail andValue:value];
    }
    else
    {
        [self.label setText:@""];
    }
    
}


-(NSString*)formatDateTime:(ALUserDetail*)alUserDetail  andValue:(double)value{
    
    NSDate *date  = [[NSDate alloc] initWithTimeIntervalSince1970:value/1000];
    
    NSDate *current = [[NSDate alloc] init];
    NSTimeInterval difference =[current timeIntervalSinceDate:date];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *todaydate = [format stringFromDate:current];
    NSString *yesterdaydate =[format stringFromDate:yesterday];
    NSString *serverdate =[format stringFromDate:date];
    
    if([serverdate compare:todaydate] == NSOrderedSame)
    {
        NSString *str = @"Last seen ";
        
        if(alUserDetail.connected)
        {
            [self.label setText:@"Online"];
            
        }
        else if(difference <= 60)
        {
            [self.label setText:@"Last seen Just Now"];
        }
        else
        {
            NSString *theTime;
            int hours =  difference / 3600;
            int minutes = (difference - hours * 3600 ) / 60;
            
            if(hours > 0){
                theTime = [NSString stringWithFormat:@"%.2d:%.2d", hours, minutes];
                if([theTime hasPrefix:@"0"])
                {
                    theTime = [theTime substringFromIndex:[@"0" length]];
                }
                str = [str stringByAppendingString:theTime];
                str = [str stringByAppendingString:@" hrs ago"];
            }
            else{
                theTime = [NSString stringWithFormat:@"%.2d", minutes];
                if([theTime hasPrefix:@"0"])
                {
                    theTime = [theTime substringFromIndex:[@"0" length]];
                }
                str = [str stringByAppendingString:theTime];
                str = [str stringByAppendingString:@" mins ago"];
            }
            [self.label setText:str];
        }
        
    }
    else if ([serverdate compare:yesterdaydate] == NSOrderedSame)
    {
        NSString *str = @"Last seen yesterday ";
        [format setDateFormat:@"hh:mm a"];
        str = [str stringByAppendingString:[format stringFromDate:date]];
        if([str hasPrefix:@"0"])
        {
            str = [str substringFromIndex:[@"0" length]];
        }
        [self.label setText:str];
    }
    else
    {
        [format setDateFormat:@"EE, MMM dd, yyy"];
        NSString *str = @"Last seen ";
        str = [str stringByAppendingString:[format stringFromDate:date]];
        [self.label setText:str];
    }
    
    return self.label.text;
    
}
-(NSArray*)getLastSeenForGroupDetails{
    
    NSMutableArray * userDetailsArray = [[NSMutableArray alloc] init];
    
    ALContactService * contactDBService = [[ALContactService alloc] init];
    
    ALChannelDBService * channelDBService = [[ALChannelDBService alloc] init];
    NSMutableArray *memberIdArray= [NSMutableArray arrayWithArray:[channelDBService getListOfAllUsersInChannel:self.channelKey]];
    [memberIdArray removeObject:[ALUserDefaultsHandler getUserId]];
    for (NSString * userID in memberIdArray) {
        ALContact * contact = [contactDBService loadContactByKey:@"userId" value:userID];
        ALUserDetail * userDetails = [[ALUserDetail alloc] init];
        userDetails.userId = userID;
        userDetails.lastSeenAtTime = contact.lastSeenAt;
        
        double value = contact.lastSeenAt.doubleValue;
        [userDetailsArray addObject:[self formatDateTime:userDetails andValue:value]];
    }
    NSLog(@"Memeber LastSeen:%@",userDetailsArray);
    return userDetailsArray;
}
//======================================================
#pragma textview delegate
//======================================================

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if(self.alContact.applicationId == NULL)
    {
        self.alContact.applicationId = [ALUserDefaultsHandler getApplicationKey];
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(self.alContact.applicationId == NULL)
    {
        self.alContact.applicationId = [ALUserDefaultsHandler getApplicationKey];
    }
    if(typingStat == YES && !self.channelKey)
    {
        typingStat = NO;
        [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
}

-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    
    float scrollOffset = scrollView.contentOffset.y;
    BOOL doneConversation =  NO;
    BOOL doneOtherwise = NO;
    
    if(self.conversationId){
        doneConversation = ([ALUserDefaultsHandler isShowLoadEarlierOption:[self.conversationId stringValue]]
                                 && [ALUserDefaultsHandler isServerCallDoneForMSGList:[self.conversationId stringValue]]);
        
    }
    else{
        NSString * IDs = (self.channelKey ? [self.channelKey stringValue] : self.contactIds);
        doneOtherwise = ([ALUserDefaultsHandler isShowLoadEarlierOption:IDs]
                                 && [ALUserDefaultsHandler isServerCallDoneForMSGList:IDs]);
    
    }
    
    if (scrollOffset == 0 && (doneConversation || doneOtherwise))
    {
        
        [self.loadEarlierAction setHidden:NO];
        
    }
    else
    {
        [self.loadEarlierAction setHidden:YES];
    }
}
- (void)textViewDidChange:(UITextView *)textView{
    
    if(typingStat == NO && !self.channelKey)
    {
        typingStat = YES;
        [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
}
//------------------------------------------------------------------------------------------------------------------
#pragma mark - MQTT Service delegate methods
//------------------------------------------------------------------------------------------------------------------

-(void) syncCall:(ALMessage *) alMessage {
    
    [self syncCall:alMessage updateUI:[NSNumber numberWithInt: 1] alertValue:alMessage.message];
}


-(void) delivered:(NSString *)messageKey contactId:(NSString *)contactId {
    if ([[self contactIds] isEqualToString: contactId]) {
        [self updateDeliveryReport: messageKey];
    }
}

-(void) updateDeliveryStatusForContact: (NSString *) contactId {
    if ([[self contactIds] isEqualToString: contactId]) {
        [self updateDeliveryReportForConversation];
    }
}

-(void) updateTypingStatus:(NSString *)applicationKey userId:(NSString *)userId status:(BOOL)status
{
    
    if ([self.contactIds isEqualToString:userId])
    {
        [self showTypingLabel:status userId:userId];
    }
}

-(void) mqttConnectionClosed {
    if (_mqttRetryCount > MQTT_MAX_RETRY|| !(self.isViewLoaded && self.view.window) ) {
        return;
    }
    
    if([ALDataNetworkConnection checkDataNetworkAvailable])
        NSLog(@"MQTT connection closed, subscribing again: %lu", (long)_mqttRetryCount);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.mqttObject subscribeToConversation];
        
    });
    _mqttRetryCount++;
}

- (void)appWillEnterForegroundInChat:(NSNotification *)notification {
    NSLog(@"will enter foreground notification");
    // [self syncCall:self.contactIds updateUI:nil alertValue:nil];
}
-(void)addMessageToList: (NSMutableArray  *)messageList{
    
    NSCompoundPredicate *compoundPredicate;
    
    if(self.isGroup){
        NSPredicate * groupP=[NSPredicate predicateWithFormat:@"groupId = %@",self.channelKey];
        compoundPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:@[groupP]];
    }
    else{  //self.channelKey not Nil
        NSPredicate *groupPredicate=[NSPredicate predicateWithFormat:@"groupId == %d or groupId == nil",0];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"contactIds == %@",self.contactIds];
        compoundPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:@[groupPredicate,predicate]];
    }
    
    NSArray * theFilteredArray = [messageList filteredArrayUsingPredicate:compoundPredicate];
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray *sortedArray = [theFilteredArray sortedArrayUsingDescriptors:descriptors];
    if(sortedArray.count==0){
        NSLog(@"No message for contact .....%@",self.contactIds);
        return;
    }
    [self.alMessageWrapper addLatestObjectToArray:(NSMutableArray *)sortedArray];
    //[ALUserService processContactFromMessages:messageList];
    [self setTitle];
    //    [self fetchAndRefresh:true];
    [self.mTableView reloadData];
    [self scrollTableViewToBottomWithAnimation:YES];
}

-(void)newMessageHandler:(NSNotification *) notification{
    
    NSMutableArray * messageArray = notification.object;
    // if([self.alMessageWrapper g])
    [self addMessageToList:messageArray];
    [self processMarkRead];
}
-(void)appWillResignActive {
    
    if(typingStat == YES && !self.channelKey)
    {
        typingStat = NO;
        [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
    
}

-(BOOL) isGroup{
    
    return !(self.channelKey==nil || [self.channelKey intValue]==0 || self.channelKey== NULL);
    
}

-(void) showVideoFullScreen:(MPMoviePlayerViewController *)fullView
{
    [self presentMoviePlayerViewControllerAnimated: fullView];
}

/*
 self.contactIds startIndex:@"0" pageSize:@"50" endTimeInTimeStamp:time andChannelKey:self.channelKey;
 */

@end
