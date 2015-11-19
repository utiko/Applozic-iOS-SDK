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

@interface ALChatViewController ()<ALChatCellImageDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,ALLocationDelegate>

@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic,assign) int rp;

@property (nonatomic,assign) NSUInteger mTotalCount;

@property (nonatomic,retain) UIImagePickerController * mImagePicker;
@property (nonatomic)  ALLocationManager * alLocationManager;
@property (nonatomic,weak) NSIndexPath *indexPathofSelection;
@end

@implementation ALChatViewController{
    
    UIActivityIndicatorView *loadingIndicator;
    NSString *messageId;


}

ALMessageDBService  * dbService;
//------------------------------------------------------------------------------------------------------------------
    #pragma mark - View lifecycle
//------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetUp];
    [self fetchMessageFromDB];
    [ALMessageService markConversationAsRead: self.contactIds withCompletion:^(NSString* string,NSError* error){
        if(!error ){
            NSLog(@"No Error");
        }
        else{
            NSLog(@"some error");
            ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
            [messageDBService getUnreadMessages:@"applozic"];
        }
    }];
    
    [self loadChatView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden: YES];
//    NSLog(@"viewWillAppear will be called ....");


    if(self.refresh || (self.mMessageListArray && self.mMessageListArray.count == 0) ||
            !(self.mMessageListArray && [[self.mMessageListArray[0] contactIds] isEqualToString:self.contactIds])
       ) {
        [self reloadView];
        [super scrollTableViewToBottomWithAnimation:NO];
        if (self.refresh) {
            self.refresh = false;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(individualNotificationhandler:) name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeliveryStatus:) name:@"deliveryReport" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden: YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deliveryReport" object:nil];
    [self.sendMessageTextView resignFirstResponder];
}

//------------------------------------------------------------------------------------------------------------------
    #pragma mark - SetUp/Theming
//------------------------------------------------------------------------------------------------------------------

-(void)initialSetUp {
    self.rp = 20;
    self.startIndex = 0;
    self.mMessageListArray = [NSMutableArray new];
    self.mImagePicker = [[UIImagePickerController alloc] init];
    self.mImagePicker.delegate = self;

   // self.sendMessageTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter message here" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    
    [self.mTableView registerClass:[ALChatCell class] forCellReuseIdentifier:@"ChatCell"];
    [self.mTableView registerClass:[ALChatCell_Image class] forCellReuseIdentifier:@"ChatCell_Image"];

    [self setTitle];

}

-(void) setTitle {
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    _alContact = [theDBHandler loadContactByKey:@"userId" value: self.contactIds];
    self.navigationItem.title = [_alContact displayName];
}

-(void)fetchMessageFromDB {

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    theRequest.predicate = [NSPredicate predicateWithFormat:@"contactId = %@",self.contactIds];
    self.mTotalCount = [theDbHandler.managedObjectContext countForFetchRequest:theRequest error:nil];
   // NSLog(@"%lu",(unsigned long)self.mTotalCount);
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
    [ self fetchAndRefresh ];
    [loadingIndicator stopAnimating];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma  mark - ALMapViewController Delegate Methods -
-(void) getUserCurrentLocation:googleMapUrl
{
    
    ALMessage * theMessage = [self getMessageToPost];
    theMessage.message=googleMapUrl;
    [self.mMessageListArray addObject:theMessage];
    [self.mTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super scrollTableViewToBottomWithAnimation:YES];
    });
    // save message to db
    [self.sendMessageTextView setText:nil];
    self.mTotalCount = self.mTotalCount+1;
    self.startIndex = self.startIndex + 1;
    [ self sendMessage:theMessage];
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - UIMenuController Actions
//------------------------------------------------------------------------------------------------------------------


// Default copy method
- (void)copy:(id)sender {
    
    NSLog(@"Copy in ALChatViewController, messageId: %@", messageId);
    ALMessage * alMessage =  [self getMessageFromViewList:@"key" withValue:messageId ];

    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    /*UITableViewCell *cell = [self.mTableView cellForRowAtIndexPath:self.indexPathofSelection];*/
    if(alMessage.message!=NULL){
    
    //[pasteBoard setString:cell.textLabel.text];
    [pasteBoard setString:alMessage.message];
    }
    else{
    [pasteBoard setString:@""];
    }
}


-(void)deleteAction:(id)sender{
    NSLog(@"Delete Menu item Pressed");
    [ALMessageService deleteMessage:messageId andContactId:self.contactIds withCompletion:^(NSString* string,NSError* error){
        if(!error ){
            NSLog(@"No Error");
        }
        else{
            NSLog(@"some error");
        }
    }];
    
    [self.mMessageListArray removeObjectAtIndex:self.indexPathofSelection.row];
    [UIView animateWithDuration:1.5 animations:^{
        //      [self loadChatView];
        [self.mTableView reloadData];
    }];
    
    
    
}

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
    [self.mMessageListArray addObject:theMessage];
    [self.mTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super scrollTableViewToBottomWithAnimation:YES];
    });
    // save message to db
    [self.sendMessageTextView setText:nil];
    self.mTotalCount = self.mTotalCount+1;
    self.startIndex = self.startIndex + 1;
    [ self sendMessage:theMessage];
}


//------------------------------------------------------------------------------------------------------------------
    #pragma mark - TableView Datasource
//------------------------------------------------------------------------------------------------------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.mMessageListArray.count > 0 ? self.mMessageListArray.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ALMessage * theMessage = self.mMessageListArray[indexPath.row];

    if([theMessage.message hasPrefix:@"http://maps.googleapis.com/maps/api/staticmap"]){
        
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALMessage * theMessage = self.mMessageListArray[indexPath.row];
    
    if((theMessage.message.length > 0) && (theMessage.fileMeta.thumbnailUrl!=nil))
    {
        
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:@"Helvetica-Bold" fontSize:15];
        
        return theTextSize.height + self.view.frame.size.width - 30;
    }
    
    else if (theMessage.fileMeta.thumbnailUrl == nil) {
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:@"Helvetica-Bold" fontSize:15];
        int extraSpace = 40 ;
        return theTextSize.height+21+extraSpace;
    }
    else
    {
        return self.view.frame.size.width-110+40;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
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
    theMessage.createdAtTime = @((long long)([[NSDate date] timeIntervalSince1970] * 1000.0)).stringValue;
    NSLog(@" Date TIme stamp::: %@",     theMessage.createdAtTime );
    theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString ];
    theMessage.message = self.sendMessageTextView.text;//3
    theMessage.sendToDevice = NO;
    theMessage.sent = NO;
    theMessage.shared = NO;
    theMessage.fileMeta = nil;
    theMessage.read = NO;
    theMessage.storeOnDevice = NO;
    theMessage.key = [[NSUUID UUID] UUIDString];
    theMessage.delivered=NO;
    theMessage.fileMetaKey = nil;//4

    return theMessage;
}

-(ALFileMetaInfo *) getFileMetaInfo {

    ALFileMetaInfo *info = [ALFileMetaInfo new];

    info.blobKey = nil;
    info.contentType = @"";
    info.createdAtTime = @"";
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
    BOOL isLoadEarlierTapped = self.mMessageListArray.count == 0 ? NO : YES ;
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setFetchLimit:self.rp];
    theRequest.predicate = [NSPredicate predicateWithFormat:@"contactId = %@",self.contactIds];
    [theRequest setFetchOffset:self.startIndex];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];

    for (DB_Message * theEntity in theArray) {
        ALMessage * theMessage = [messageDBService createMessageEntity:theEntity];
        [self.mMessageListArray insertObject:theMessage atIndex:0];
        //[self.mMessageListArrayKeyStrings insertObject:theMessage.key atIndex:0];
    }

    [self.mTableView reloadData];

    if (isLoadEarlierTapped) {
        if ((theArray != nil && theArray.count < self.rp )|| self.mMessageListArray.count == self.mTotalCount) {
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
        if (theArray.count < self.rp || self.mMessageListArray.count == self.mTotalCount) {
            self.mTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        else
        {
            self.mTableView.tableHeaderView = self.mTableHeaderView;
        }
        self.startIndex = theArray.count;

        if (self.mMessageListArray.count != 0) {
            CGRect theFrame = [self.mTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:theArray.count-1 inSection:0]];
            [self.mTableView setContentOffset:CGPointMake(0, theFrame.origin.y)];
        }

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
    
    [ALMessageService deleteMessage:message.key andContactId:self.contactIds withCompletion:^(NSString* string,NSError* error){
        if(!error ){
            NSLog(@"No Error");
        }
    }];
    
    [self.mMessageListArray removeObject:message];
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
        DB_Message *dbMessage =(DB_Message*)[dbService getMeesageById:message.msgDBObjectId error:&error];
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
    
    ALChatCell_Image*  cell=  [self getCell:connection.keystring];
    NSLog(@"found cell .. %@", cell);
    cell.mMessage.fileMeta.progressValue = [self bytesConvertsToDegree:totalBytesExpectedToWrite comingBytes:totalBytesWritten];
    
    NSLog(@" didSendBodyData...." );
    
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
        NSLog(@"f####ileName :: %@",message.fileMeta.name);
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
    
   // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    //
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
    
    [self.mMessageListArray addObject:theMessage];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    DB_Message * theMessageEntity = [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    theMessage.msgDBObjectId = [theMessageEntity objectID];
    
    [self uploadImage:theMessage];
    [self.mTableView reloadData];
    [self scrollTableViewToBottomWithAnimation:NO];
    
}


-(void)uploadImage:(ALMessage *)theMessage {
   
    if (theMessage.fileMeta && [theMessage.type isEqualToString:@"5"]) {
        NSDictionary * userInfo = [theMessage dictionary];
        [self.sendMessageTextView setText:nil];
        self.mTotalCount = self.mTotalCount+1;
        self.startIndex = self.startIndex + 1;
        
        ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.mMessageListArray indexOfObject:theMessage] inSection:0]];
        if (imageCell == nil) {
            //            [self performSelector:@selector(uploadImage:)
            //                       withObject:objects
            //                       afterDelay:1];
            [UIView animateWithDuration:.50 animations:^{
                [self scrollTableViewToBottomWithAnimation:YES];
            } completion:^(BOOL finished) {
                [self uploadImage:theMessage];
            }];
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
        [ALMessageService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
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
//    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"take photo",@"photo library", nil];
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
    
    int index=(int) [self.mMessageListArray indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop)
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
            return ;
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
    
    NSArray * filteredArray = [self.mMessageListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",key,value]];
    if (filteredArray.count > 0) {
        return filteredArray[0];
    }

    return nil;
}


-(void)fetchAndRefresh{
    NSString *deviceKeyString =[ALUserDefaultsHandler getDeviceKeyString ] ;
    
    [ ALMessageService getLatestMessageForUser: deviceKeyString withCompletion:^(NSMutableArray  *messageList, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            return ;
            
        } else {
            if (messageList.count > 0 ){
                NSArray * theFilteredArray = [messageList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIds = %@",self.contactIds]];
                NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:YES];
                NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
                NSArray *sortedArray = [theFilteredArray sortedArrayUsingDescriptors:descriptors];
                [[self mMessageListArray] addObjectsFromArray:sortedArray];
             
                [ALUserService processContactFromMessages:messageList];
                [self setTitle];
                [self.mTableView reloadData];
            }
           
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [super scrollTableViewToBottomWithAnimation:YES];
                [self setTitle];
               
            });
        }
    }];
    

}
-(void)updateDeliveryReport:(NSString*)key{
    
    ALMessage * alMessage =  [self getMessageFromViewList:@"key" withValue:key ];
    if (alMessage){
        alMessage.delivered=YES;
        [self.mTableView reloadData];
    }
}

-(void)individualNotificationhandler:(NSNotification *) notification
{
    [self setRefreshMainView:TRUE];
    // see if this view is visible or not...
    NSString * contactId = notification.object;
    NSDictionary *dict = notification.userInfo;
    NSNumber *updateUI = [dict valueForKey:@"updateUI"];
    NSLog(@"Notification received by Individual chat list: %@", contactId);
    
    
    if ([self.contactIds isEqualToString:contactId]) {
        //[self fetchAndRefresh];
        NSLog(@"current contact thread is opened");
        [self fetchAndRefresh];
    } else if (![updateUI boolValue]) {
        NSLog(@"it was in background, updateUI is false");
        self.contactIds = contactId;
        [self reloadView];
        [self fetchAndRefresh];
    } else {
        NSLog(@"show notification as someone else thread is already opened");
        NSString *alertValue = [dict valueForKey:@"alertValue"];
        ALNotificationView * alnotification = [[ALNotificationView alloc]initWithContactId:contactId withAlertMessage:alertValue];
        [ alnotification displayNotification:self];
        [self fetchAndRefresh];

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
    [self.mMessageListArray removeAllObjects];
    [self.mTableView reloadData];
    self.startIndex =0;
    [self fetchMessageFromDB];
    [self loadChatView];
}

-(void)handleNotification:(UIGestureRecognizer*)gestureRecognizer{
    
    ALNotificationView * notificationView = (ALNotificationView*)gestureRecognizer.view;
    
    NSLog(@" got the UI label::%@" , notificationView.contactId);
    self.contactIds = notificationView.contactId;
    [self reloadView];
    [self fetchAndRefresh];
    
}

@end
