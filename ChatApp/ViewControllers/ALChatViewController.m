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
#import "ALParsingHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageDBService.h"
#import "ALImagePickerHandler.h"
#import <CoreLocation/CoreLocation.h>


@interface ALChatViewController ()<ALChatCellImageDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic,assign) int rp;

@property (nonatomic,assign) NSUInteger mTotalCount;

@property (nonatomic,retain) UIImagePickerController * mImagePicker;

@end

@implementation ALChatViewController{
    
        CLLocationManager *locationManager;
        CLGeocoder *geocoder;
        CLPlacemark *placemark;
        NSString* googleURL;
        UIActivityIndicatorView *loadingIndicator;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

   }

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if( !(self.mMessageListArray.count >0 &&
          [[self.mMessageListArray[0] contactIds ] isEqualToString:self.contactIds])){
        [self.mMessageListArray removeAllObjects];
        self.startIndex =0;
        [self fetchMessageFromDB];
        [self loadChatView];
        [super scrollTableViewToBottomWithAnimation:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(individualNotificationhandler:) name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeliveryStatus:) name:@"deliveryReport" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notificationIndividualChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deliveryReport" object:nil];

}

//------------------------------------------------------------------------------------------------------------------
    #pragma mark - SetUp/Theming
//------------------------------------------------------------------------------------------------------------------

-(void)initialSetUp {
    self.rp = 20;
    self.startIndex = 0 ;
    self.mMessageListArray = [NSMutableArray new];
    self.mImagePicker = [[UIImagePickerController alloc] init];
    self.mImagePicker.delegate = self;

    self.mSendMessageTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter message here" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];

    [self.mTableView registerClass:[ALChatCell class] forCellReuseIdentifier:@"ChatCell"];
    [self.mTableView registerClass:[ALChatCell_Image class] forCellReuseIdentifier:@"ChatCell_Image"];

    self.navigationItem.title = self.contactIds;
}

-(void)fetchMessageFromDB {

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    theRequest.predicate = [NSPredicate predicateWithFormat:@"contactId = %@",self.contactIds];
    self.mTotalCount = [theDbHandler.managedObjectContext countForFetchRequest:theRequest error:nil];
    NSLog(@"%lu",(unsigned long)self.mTotalCount);
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

//------------------------------------------------------------------------------------------------------------------
    #pragma mark - IBActions
//------------------------------------------------------------------------------------------------------------------

-(void) postMessage
{
    ALMessage * theMessage = [self getMessageToPost];
    [self.mMessageListArray addObject:theMessage];
    [self.mTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super scrollTableViewToBottomWithAnimation:YES];
    });
    // save message to db
    [self.mSendMessageTextField setText:nil];
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

    if (theMessage.fileMetas.thumbnailUrl == nil ) { // textCell
        
        ALChatCell *theCell = (ALChatCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
        theCell.tag = indexPath.row;
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
    if (theMessage.fileMetas.thumbnailUrl == nil) {
        CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:@"Helvetica-Bold" fontSize:15];
        int extraSpace = 40 ;
        return theTextSize.height+21+extraSpace;
    }
    else
    {
        return self.view.frame.size.width-110+40;
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
    theMessage.createdAtTime = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]*1000];
    theMessage.deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString ];
    theMessage.message = self.mSendMessageTextField.text;//3
    theMessage.sendToDevice = NO;
    theMessage.sent = NO;
    theMessage.shared = NO;
    theMessage.fileMetas = nil;
    theMessage.read = NO;
    theMessage.storeOnDevice = NO;
    theMessage.keyString = @"test keystring";
    theMessage.delivered=NO;
    theMessage.fileMetaKeyStrings = @[];//4

    return theMessage;
}

-(ALFileMetaInfo *) getFileMetaInfo {

    ALFileMetaInfo *info = [ALFileMetaInfo new];

    info.blobKeyString = @"";
    info.contentType = @"";
    info.createdAtTime = @"";
    info.keyString = @"";
    info.name = @"";
    info.size = @"";
    info.suUserKeyString = @"";
    info.thumbnailUrl = @"";
    info.progressValue = 0;

    return info;
}


#pragma mark helper methods

-(void) loadChatView
{
    self.navigationItem.title = self.contactIds;

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
        ALMessage * theMessage = [ messageDBService createMessageForSMSEntity:theEntity];
        [self.mMessageListArray insertObject:theMessage atIndex:0];
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

    NSLog(@"%@",[UIDevice currentDevice].systemVersion);

    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 ) { // ios 7 and previous

        [self showActionSheet];

    }
    else // ios 8
    {

        [self showActionAlert];
    }


}

#pragma mark chatCellImageDelegate

-(void)downloadRetryButtonActionDelegate:(int)index andMessage:(ALMessage *)message
{
    ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    imageCell.progresLabel.alpha = 1;
    imageCell.mMessage.fileMetas.progressValue = 0;
    imageCell.mDowloadRetryButton.alpha = 0;
    message.inProgress = YES;

    NSMutableArray * theCurrentConnectionsArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
    NSArray * theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.keyString]];
    if (theFiletredArray.count == 0){
        message.isUploadFailed = NO;
        message.inProgress=YES;
        
        NSError *error =nil;
        DB_Message *dbMessage =(DB_Message*)[dbService getMeesageById:message.msgDBObjectId error:&error];
        dbMessage.inProgress = [NSNumber numberWithBool:YES];
        dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
        
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        if ([message.type isEqualToString:@"5"]) { // upoad
            [self uploadImage:message];
        }else { //download
            [ALMessageService processImageDownloadforMessage:message withdelegate:self];
        }
    }else{
        NSLog(@"connection already present do nothing###");
    }
   
}

-(void)stopDownloadForIndex:(int)index andMessage:(ALMessage *)message {
    
    ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    imageCell.progresLabel.alpha = 0;
    imageCell.mDowloadRetryButton.alpha = 1;
    message.inProgress = NO;
    [self handleErrorStatus:message];
    if ([message.type isEqualToString:@"5"]) { // retry or cancel
        
        [self releaseConnection:message.imageFilePath];
    }
    else // download or cancel
    {
         [self releaseConnection:message.keyString];
         [self handleErrorStatus:message];
    }

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
    cell.progresLabel.endDegree = [self bytesConvertsToDegree:[cell.mMessage.fileMetas.size floatValue] comingBytes:(CGFloat)connection.mData.length];;
    
}


-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    ALChatCell_Image*  cell=  [self getCell:connection.keystring];
    cell.mMessage.fileMetas.progressValue = [self bytesConvertsToDegree:totalBytesExpectedToWrite comingBytes:totalBytesWritten];
    
}

//Finishing

-(void)connectionDidFinishLoading:(ALConnection *)connection {
    
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    dbService = [[ALMessageDBService alloc]init];

    if ([connection.connectionType isEqualToString:@"Image Posting"]) {
        ALMessage * message = [self getMessageFromViewList:@"imageFilePath" withValue:connection.keystring];
        NSLog(@"found message : %@", message);
        //get it fromDB ...we can move it to thread as nothing to show to user
        if(!message){
            DB_Message * dbMessage = (DB_Message*)[dbService getMessageByKey:@"filePath" value:connection.keystring];
            message = [ dbService createMessageForSMSEntity:dbMessage];
        }
        NSError * theJsonError = nil;
        NSDictionary *theJson = [NSJSONSerialization JSONObjectWithData:connection.mData options:NSJSONReadingMutableLeaves error:&theJsonError];
        NSDictionary *fileInfo = [theJson objectForKey:@"fileMeta"];
        [message.fileMetas populate:fileInfo ];
        ALMessage * almessage =  [ALMessageService processFileUploadSucess:message];
        
        [self sendMessage:almessage ];
    }else {
        
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.local",connection.keystring]];
        [connection.mData writeToFile:filePath atomically:YES];
        // update db
        DB_Message * smsEntity = (DB_Message*)[dbService getMessageByKey:@"keyString" value:connection.keystring];
        smsEntity.inProgress = [NSNumber numberWithBool:NO];
        smsEntity.isUploadFailed=[NSNumber numberWithBool:NO];
        smsEntity.filePath = [NSString stringWithFormat:@"%@.local",connection.keystring];
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        ALMessage * message = [self getMessageFromViewList:@"keyString" withValue:connection.keystring];
        if(message){
            message.isUploadFailed =NO;
            message.inProgress=NO;
            message.imageFilePath =  smsEntity.filePath;
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
    [self dismissViewControllerAnimated:YES completion:nil];

    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image getCompressedImageLessThanSize:5];

    // save image to doc
    NSString * filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
    // create message object
    ALMessage * theMessage = [self getMessageToPost];
    theMessage.fileMetas = [self getFileMetaInfo];
    theMessage.imageFilePath = filePath.lastPathComponent;
    NSData *imageSize = [NSData dataWithContentsOfFile:filePath];
    theMessage.fileMetas.size = [NSString stringWithFormat:@"%lu",(unsigned long)imageSize.length];
    //theMessage.fileMetas.thumbnailUrl = filePath.lastPathComponent;

    // save msg to db
    
    [self.mMessageListArray addObject:theMessage];
    [self.mTableView reloadData];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    DB_Message * theSmsEntity = [messageDBService createSMSEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    theMessage.msgDBObjectId = [theSmsEntity objectID];
    dispatch_async(dispatch_get_main_queue(), ^{

            [UIView animateWithDuration:.50 animations:^{
            [self scrollTableViewToBottomWithAnimation:YES];
        } completion:^(BOOL finished) {
            [self uploadImage:theMessage];
        }];
    });
}

-(void)uploadImage:(ALMessage *)theMessage {
   
    if (theMessage.fileMetas && [theMessage.type isEqualToString:@"5"]) {
        NSDictionary * userInfo = [theMessage dictionary];
        [self.mSendMessageTextField setText:nil];
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
        imageCell.mMessage.fileMetas.progressValue = 0;
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
        
        [self getLocation];
        
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

-(void) getLocation
{
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    [locationManager startUpdatingLocation];
    //[locationManager requestLocation];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
//        [alert show];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        googleURL=[NSString stringWithFormat:@"https://www.google.com/maps?q=%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude ];
        
        NSLog(@"::::GOOGLE URL:::: %@",googleURL );
        
    }
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            
            NSString* AddressLabel = [NSString stringWithFormat:@"\n%@\n%@ %@\n%@",
                                      /*placemark.subThoroughfare, placemark.thoroughfare,*/
                                      placemark.locality,
                                      placemark.administrativeArea,placemark.postalCode,
                                      placemark.country];
            NSLog(@"::::ADDRESS::: %@",AddressLabel);
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

-(void) handleErrorStatus:(ALMessage *) message{
    [ALUtilityClass displayToastWithMessage:@"network error." ];
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
    ALConnection * connection = [[theConnectionArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@",key]] objectAtIndex:0];
    [connection cancel];
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
}

-(ALChatCell_Image *) getCell:(NSString *)key{
    
    int index=(int) [self.mMessageListArray indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop)
                     {
                         ALMessage *message = (ALMessage*)element;
                         
                         if( ([ message.type isEqualToString:@"4" ]&& [ message.keyString isEqualToString:key ] )||
                            ([ message.type isEqualToString:@"5" ]&& [ message.imageFilePath isEqualToString:key ]) )
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
               
            }
            NSLog(@" message json from client, lastSyncTime ::%@",[ALUserDefaultsHandler
                                                      getLastSyncTime ] );
            [self.mTableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [super scrollTableViewToBottomWithAnimation:YES];
            });
        }
    }];
    

}
-(void)updateDeliveryReport:(NSString*)keyString{
    
    ALMessage * alMessage =  [self getMessageFromViewList:@"keyString" withValue:keyString ];
    if (alMessage){
        alMessage.delivered=YES;
        [self.mTableView reloadData];
    }
}

-(void)individualNotificationhandler:(NSNotification *) notification
{
    
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
        [self.mMessageListArray removeAllObjects];
        [self.mTableView reloadData];
        
        self.contactIds = contactId;
        [self fetchMessageFromDB];
        [self loadChatView];
    } else {
        NSLog(@"show notification as someone else thread is already opened");
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = notification.userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        NSString *alertValue = [[notification.userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        
        localNotification.alertBody = alertValue;
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }

}

-(void)updateDeliveryStatus:(NSNotification *) notification
{
    NSString * keyString = notification.object;
    [self updateDeliveryReport:keyString];
}


@end
