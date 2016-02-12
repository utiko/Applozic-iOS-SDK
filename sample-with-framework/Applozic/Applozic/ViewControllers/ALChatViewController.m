//
//  ALChatViewController.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

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
#import "ALChatCell_Image.h"
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

#define MQTT_MAX_RETRY 3
#define NEW_MESSAGE_NOTIFICATION @"newMessageNotification"


@interface ALChatViewController ()<ALChatCellImageDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,ALLocationDelegate,ALMQTTConversationDelegate>

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

- (IBAction)loadEarlierButtonAction:(id)sender;
-(void)processLoadEarlierMessages:(BOOL)flag;
-(void)processMarkRead;
-(void)fetchAndRefresh:(BOOL)flag;
-(void)serverCallForLastSeen;

@end

@implementation ALChatViewController{
    
    UIActivityIndicatorView *loadingIndicator;
    NSString *messageId;
    BOOL typingStat;
    
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
    [ALMessageService markConversationAsRead: self.contactIds orChannelKey:self.channelKey withCompletion:^(NSString* string,NSError* error){
        if(!error) {
            NSLog(@"Marked messages as read for %@", self.contactIds);
        }
        else {
            NSLog(@"Error while marking messages as read.");
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
    [self.loadEarlierAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loadEarlierAction setBackgroundColor:[UIColor grayColor]];
    [self processMarkRead];
//    if(self.individualLaunch){
//        [self fetchAndRefresh:YES];
//    }
    
//    [self.label setTextColor:[UIColor whiteColor]];

}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [ALApplozicSettings getColourForNavigationItem], NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:18]}];
    [navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColourForNavigation]];
    [navigationController.navigationBar setTintColor:[ALApplozicSettings getColourForNavigationItem]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // [ALUserService updateUserDisplayName:self.alContact];
    [self.tabBarController.tabBar setHidden: YES];
    [self.label setHidden:NO];
    [self.loadEarlierAction setHidden:YES];
    self.showloadEarlierAction = TRUE;
    self.typingLabel.hidden = YES;
    typingStat=NO;
    if(self.refresh || ([self.alMessageWrapper getUpdatedMessageArray] && [self.alMessageWrapper getUpdatedMessageArray].count == 0) || (((!([self.alMessageWrapper getUpdatedMessageArray] && [[[self.alMessageWrapper getUpdatedMessageArray][0] contactIds] isEqualToString:self.contactIds])))||([[self.alMessageWrapper getUpdatedMessageArray][0] groupId] != self.channelKey)))
    {
        [self reloadView];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(individualNotificationhandler:) name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeliveryStatus:) name:@"deliveryReport" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(newMessageHandler:) name:NEW_MESSAGE_NOTIFICATION  object:nil];
    
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

    if(![ALUserDefaultsHandler isServerCallDoneForMSGList:self.contactIds])
    {
        NSLog(@"called first time .....");
        [self processLoadEarlierMessages:true];
    }
    if(self.text)
    {
        self.sendMessageTextView.text = self.text;
    }
 
    NSLog(@"view will appers CHANNEL KEY %@", self.channelKey);
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
    
    // self.sendMessageTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter message here" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    
    [self.mTableView registerClass:[ALChatCell class] forCellReuseIdentifier:@"ChatCell"];
    [self.mTableView registerClass:[ALChatCell_Image class] forCellReuseIdentifier:@"ChatCell_Image"];
    
    [self setTitle];
    
}

-(void) setTitle {
    if(self.displayName){
        ALContactService * contactService = [[ALContactService alloc] init];
        _alContact = [contactService loadOrAddContactByKeyWithDisplayName:self.contactIds value: self.displayName];
        
    }else{
        ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
        _alContact = [theDBHandler loadContactByKey:@"userId" value: self.contactIds];
        
    }
    
    self.navigationItem.title = [_alContact displayName];
    if(self.channelKey != nil)
    {
        ALChannelService *channelService = [[ALChannelService alloc] init];
        self.navigationItem.title = [channelService getChannelName:self.channelKey];
    }
    ALUserDetail *userDetail = [[ALUserDetail alloc] init];
    userDetail.connected = self.alContact.connected;
    userDetail.userId = self.alContact.userId;
    userDetail.lastSeenAtTime = self.alContact.lastSeenAt;
    [self updateLastSeenAtStatus:userDetail];
}


-(void)fetchMessageFromDB {
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    if(self.channelKey){
        theRequest.predicate = [NSPredicate predicateWithFormat:@"groupId=%d",[self.channelKey intValue]];
    }else{
         theRequest.predicate = [NSPredicate predicateWithFormat:@"contactId = %@" ,self.contactIds];
    }
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
-(void) getUserCurrentLocation:(NSString *)googleMapUrl
{
    if(googleMapUrl.length != 0)
    {
        ALMessage * theMessage = [self getMessageToPost];
        theMessage.message = googleMapUrl;
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
    else
    {
        NSString *alertMsg = @"Unable to fetch current location. Try Again!!!";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Current Location" message:alertMsg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        
        [alertView show];
        
    }
    
}

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
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"Empty" message:@"Did you forget to type the message?" delegate:self
                                                 cancelButtonTitle:nil otherButtonTitles:@"Yes, Let me add something", nil];
        [alertView show];
        return;
    }
    ALMessage * theMessage = [self getMessageToPost];
    [self.alMessageWrapper addALMessageToMessageArray:theMessage];
    NSLog(@"Message  %@",theMessage.message);
    [self.mTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super scrollTableViewToBottomWithAnimation:YES];
    });
    // save message to db
    [self.sendMessageTextView setText:nil];
    self.mTotalCount = self.mTotalCount + 1;
    self.startIndex = self.startIndex + 1;
    [self sendMessage:theMessage];
    if(typingStat == YES){
        typingStat = NO;
    [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - TableView Datasource
//------------------------------------------------------------------------------------------------------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.alMessageWrapper getUpdatedMessageArray].count > 0 ? [self.alMessageWrapper getUpdatedMessageArray].count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALMessage * theMessage = [self.alMessageWrapper getUpdatedMessageArray][indexPath.row];
    
//    if([theMessage.message hasPrefix:@"http://maps.googleapis.com/maps/api/staticmap"]){
    if(theMessage.contentType==ALMESSAGE_CONTENT_LOCATION){

        ALChatCell_Image *theCell = (ALChatCell_Image *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell_Image"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        theCell.backgroundColor = [UIColor clearColor];
        [theCell populateCell:theMessage viewSize:self.view.frame.size ];
        [self.view layoutIfNeeded];
        return theCell;
        
    }
    if (theMessage.fileMeta.thumbnailUrl == nil ) { // textCell
        
        ALChatCell *theCell = (ALChatCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        [theCell populateCell:theMessage viewSize:self.view.frame.size ];
        return theCell;
        
    }
    else
    {
        ALChatCell_Image *theCell = (ALChatCell_Image *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell_Image"];
        theCell.tag = indexPath.row;
        theCell.delegate = self;
        theCell.backgroundColor = [UIColor clearColor];
        [theCell populateCell:theMessage viewSize:self.view.frame.size ];
        [self.view layoutIfNeeded];
        return theCell;
        
    }
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
    
    if((theMessage.message.length > 0) && (theMessage.fileMeta.thumbnailUrl!=nil))
    {
        
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:@"Helvetica-Bold" fontSize:15];
        
        return theTextSize.height + self.view.frame.size.width - 30;
    }
    
    if([theMessage.type isEqualToString:@"100" ])
    {
        return 30;
    }
    else if (theMessage.fileMeta.thumbnailUrl == nil) {
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:@"Helvetica-Bold" fontSize:15];
        int extraSpace = 50 ;
        return theTextSize.height+21+extraSpace;
    }
    else
    {
        return self.view.frame.size.width-110+40;
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
    if([self.channelKey intValue])
    {
        theMessage.groupId = self.channelKey;
    }
    else
    {
        theMessage.groupId = nil;
    }
    
    return theMessage;
}

-(ALFileMetaInfo *) getFileMetaInfo {
    
    ALFileMetaInfo *info = [ALFileMetaInfo new];
    
    info.blobKey = nil;
    info.contentType = @"";
    info.createdAtTime = nil;
    info.key =nil;
    info.name =[ [ALUtilityClass getFileNameWithCurrentTimeStamp] stringByAppendingString:@".jpeg"];
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
    if(self.channelKey){
       predicate1 = [NSPredicate predicateWithFormat:@"groupId=%d",[self.channelKey intValue]];
    }else{
       predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ and groupId=0" ,self.contactIds];
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
            self.mTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
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
            self.mTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        else
        {
            self.mTableView.tableHeaderView = self.mTableHeaderView;
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
    ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
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
    
    ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
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
    
    ALChatCell_Image*  cell=  [self getCell:connection.keystring];
    cell.progresLabel.endDegree = [self bytesConvertsToDegree:[cell.mMessage.fileMeta.size floatValue] comingBytes:(CGFloat)connection.mData.length];;
    
}


-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    ALChatCell_Image*  cell = [self getCell:connection.keystring];
    // NSLog(@"found cell .. %@", cell);
    cell.mMessage.fileMeta.progressValue = [self bytesConvertsToDegree:totalBytesExpectedToWrite comingBytes:totalBytesWritten];
    
    // NSLog(@" didSendBodyData...." );
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
        
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.local",connection.keystring]];
        [connection.mData writeToFile:filePath atomically:YES];
        // update db
        DB_Message * messageEntity = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
        messageEntity.inProgress = [NSNumber numberWithBool:NO];
        messageEntity.isUploadFailed=[NSNumber numberWithBool:NO];
        messageEntity.filePath = [NSString stringWithFormat:@"%@.local",connection.keystring];
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        ALMessage * message = [self getMessageFromViewList:@"key" withValue:connection.keystring];
        if(message){
            message.isUploadFailed =NO;
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
    
    ALChatCell_Image*  imageCell=  [self getCell:connection.keystring];
    imageCell.progresLabel.alpha = 0;
    imageCell.mDowloadRetryButton.alpha = 1;
    [self handleErrorStatus:imageCell.mMessage];
    NSLog(@"didFailWithError ::: %@",error);
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
}

#pragma mark image picker delegates

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
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    obtext.imagecontrollerDelegate = self;
    
}

-(void)check:(UIImage *)imageFile andText:(NSString *)textwithimage
{
    // save image to doc
    NSLog(@"check method of delegate and text: %@", textwithimage);
    NSString * filePath = [ALImagePickerHandler saveImageToDocDirectory:imageFile];
    // create message object
    ALMessage * theMessage = [self getMessageToPost];
    theMessage.fileMeta = [self getFileMetaInfo];
    theMessage.message = textwithimage;
    theMessage.imageFilePath = filePath.lastPathComponent;
    NSData *imageSize = [NSData dataWithContentsOfFile:filePath];
    theMessage.fileMeta.size = [NSString stringWithFormat:@"%lu",(unsigned long)imageSize.length];
    //theMessage.fileMetas.thumbnailUrl = filePath.lastPathComponent;
    
    // save msg to db
    
    [self.alMessageWrapper addALMessageToMessageArray:theMessage];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    DB_Message * theMessageEntity = [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    theMessage.msgDBObjectId = [theMessageEntity objectID];
    [self.mTableView reloadData];
    [self scrollTableViewToBottomWithAnimation:NO];
    [self uploadImage:theMessage];
    
}

-(void)uploadImage:(ALMessage *)theMessage {
    
    if (theMessage.fileMeta && [theMessage.type isEqualToString:@"5"]) {
        NSDictionary * userInfo = [theMessage dictionary];
        [self.sendMessageTextView setText:nil];
        self.mTotalCount = self.mTotalCount+1;
        self.startIndex = self.startIndex + 1;
        
        ALChatCell_Image*  imageCell=  [self getCell:theMessage.key];
        if(!imageCell){
            NSLog(@" not able to find the image cell for upload....");
            return;
        }
        imageCell.progresLabel.alpha = 1;
        imageCell.mMessage.fileMeta.progressValue = 0;
        imageCell.mDowloadRetryButton.alpha = 0;
        imageCell.mMessage.inProgress = YES;
        NSError *error=nil;
        ALMessageDBService  * dbService = [[ALMessageDBService alloc] init];
        DB_Message *dbMessage =(DB_Message*)[dbService getMeesageById:theMessage.msgDBObjectId error:&error];
        dbMessage.inProgress = [NSNumber numberWithBool:YES];
        dbMessage.isUploadFailed=[NSNumber numberWithBool:NO];
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        
        // post image
        ALMessageClientService * clientService  = [[ALMessageClientService alloc]init];
        [clientService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
            if (error) {
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
    [theController addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil]];
    [theController addAction:[UIAlertAction actionWithTitle:@"take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCamera];
    }]];
    [theController addAction:[UIAlertAction actionWithTitle:@"photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openGallery];
        
    }]];
    [theController addAction:[UIAlertAction actionWithTitle:@"current location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
        ALMapViewController *vc = (ALMapViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareLoactionViewTag"];
        vc.controllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }]];
    
    [self presentViewController:theController animated:YES completion:nil];
}


-(void) openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
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
    [self presentViewController:_mImagePicker animated:YES completion:nil];
}



-(void) handleErrorStatus:(ALMessage *) message{
    //[ALUtilityClass displayToastWithMessage:@"network error." ];
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

-(ALChatCell_Image *) getCell:(NSString *)key{
    
    int index=(int) [[self.alMessageWrapper getUpdatedMessageArray] indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop)
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
    ALChatCell_Image *cell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:path];
    
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

-(void)updateDeliveryReport:(NSString*)key{
    
    ALMessage * alMessage =  [self getMessageFromViewList:@"key" withValue:key ];
    if (alMessage){
        alMessage.delivered=YES;
        [self.mTableView reloadData];
    }else{
        //not found
        
        
        //get message from db by key
        [ALMessageService getMessagefromKeyValuePair:@"key" andValue:key];
        //and get alMessage.msgDBObjectId
        
        ALMessage* fetchMsg=[ALMessage new];
        fetchMsg=[ALMessageService getMessagefromKeyValuePair:@"key" andValue:key];
        
        //now find in list ...
        ALMessage * alMessage2 =  [self getMessageFromViewList:@"msgDBObjectId" withValue:fetchMsg.msgDBObjectId];
        
        if (alMessage2){
            alMessage2.delivered=YES;
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
    [self syncCall:contactId updateUI:updateUI alertValue:alertValue];
}

-(void) syncCall:(NSString *) contactId updateUI:(NSNumber *) updateUI alertValue: (NSString *) alertValue
{
    [self setRefreshMainView:TRUE];
    if ([self.contactIds isEqualToString:contactId]) {
        NSLog(@"current contact thread is opened");
        [self fetchAndRefresh:YES];
        //[self processMarkRead];
        NSLog(@"INDIVIDUAL NOTIFICATION HANDLER");
    }
    else if (![updateUI boolValue]) {
        NSLog(@"it was in background, updateUI is false");
        self.contactIds = contactId;
        [self fetchAndRefresh:YES];
        [self reloadView];
    }
    else {
        NSLog(@"show notification as someone else thread is already opened");
        ALNotificationView * alnotification;
        
        if(self.channelKey){
            alnotification =[[ALNotificationView alloc]
                             initWithContactId:nil
                             orGroupId:self.channelKey
                             withAlertMessage:alertValue];
        }
        else{
            self.channelKey=nil;
            alnotification =[[ALNotificationView alloc]
                             initWithContactId:contactId
                             orGroupId:nil
                             withAlertMessage:alertValue];
            //        [[ALNotificationView alloc]initWithContactId:contactId withAlertMessage:alertValue];
        }
        [alnotification displayNotificationNew:self];
        [self fetchAndRefresh:YES];

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
    if([self.alMessageWrapper getUpdatedMessageArray].count > 0 && [self.alMessageWrapper getUpdatedMessageArray] != NULL) {
        ALMessage * theMessage = [self.alMessageWrapper getUpdatedMessageArray][0];
        time = theMessage.createdAtTime;
    }
    else {
        time = NULL;
    }
    [ALMessageService getMessageListForUser:self.contactIds startIndex:@"0" pageSize:@"50" endTimeInTimeStamp:time andChannelKey:self.channelKey withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray){
        if(!error )
        {
            NSLog(@"No Error");
            self.loadEarlierAction.hidden=YES;
            if( messages.count< 50 ){
                
                [ALUserDefaultsHandler setShowLoadEarlierOption:NO forContactId:self.contactIds];
            }
            if (messages.count==0){
                [ALUserDefaultsHandler setShowLoadEarlierOption:NO forContactId:self.contactIds];
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
            self.startIndex = self.startIndex + messages.count;
            [self.mTableView reloadData];
            if(isScrollToBottom){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [super scrollTableViewToBottomWithAnimation:NO];
                });
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
    
    if(self.channelKey != nil)
    {
        ALChannelService *ob = [[ALChannelService alloc] init];
        [self.label setText:[ob stringFromChannelUserList:self.channelKey]];
    }
    else if(value > 0)
    {
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
        
    }
    else
    {
        [self.label setText:@""];
    }
    
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
    if(typingStat==YES){
        typingStat=NO;
    [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
}

-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{

    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0  && [ALUserDefaultsHandler isShowLoadEarlierOption:self.contactIds] && [ALUserDefaultsHandler isServerCallDoneForMSGList:self.contactIds])
    {
       
        [self.loadEarlierAction setHidden:NO];

    }
    else
    {
        [self.loadEarlierAction setHidden:YES];
    }
}
- (void)textViewDidChange:(UITextView *)textView{
 
    if(typingStat==NO){
        typingStat=YES;
        [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }
}
//------------------------------------------------------------------------------------------------------------------
#pragma mark - MQTT Service delegate methods
//------------------------------------------------------------------------------------------------------------------

-(void) syncCall:(ALMessage *) alMessage {
    [self syncCall:alMessage.contactIds updateUI:[NSNumber numberWithInt: 1] alertValue:alMessage.message];
    NSLog(@"syncCall:alMessage  called....GROUPiD %@ & CONTACTiD %@",alMessage.groupId,alMessage.contactIds);
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
    // NSLog(@"==== Received typing status %d for: %@ ====", status, userId);
    
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
    
    
    NSLog(@"ADD MESSAGE %@",messageList);
    NSArray * theFilteredArray = [messageList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIds = %@",self.contactIds]];
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
-(void)appWillResignActive{
    
    if(typingStat==YES){
        typingStat=NO;
        [self.mqttObject sendTypingStatus:self.alContact.applicationId userID:self.contactIds typing:typingStat];
    }

}
@end
