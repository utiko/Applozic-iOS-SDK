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
#import "DB_SMS.h"
#import "ALViewController.h"
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

@interface ALChatViewController ()<ALChatCellImageDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic,retain) UIButton * rightViewButton;

@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic,assign) int rp;

@property (nonatomic,retain) UIView * mTableHeaderView;

@property (nonatomic, retain) UIColor *navColor;

@property (nonatomic,assign) NSUInteger mTotalCount;

@property (nonatomic,retain) UIImagePickerController * mImagePicker;

@end

@implementation ALChatViewController

#pragma mark life cycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    
    if (!color) {
        color = [UIColor blackColor];
    }
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.navigationItem.title = self.mLatestMessage.contactIds;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTable:)];
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.rp = 20;
    
    self.startIndex = 0 ;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navColor = [self.navigationController.navigationBar tintColor];
    } else {
        // iOS 7.0 or later
        self.navColor = [self.navigationController.navigationBar barTintColor];
    }

    // header button
    
    self.mTableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    self.mTableHeaderView.backgroundColor = [UIColor clearColor];
    
    UIButton * mLoadEarlierMessagesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    mLoadEarlierMessagesButton.frame = CGRectMake(self.view.frame.size.width/2-90, 15, 180, 30);
    
    [mLoadEarlierMessagesButton setTitle:@"Load Earlier" forState:UIControlStateNormal];
    
    [mLoadEarlierMessagesButton setBackgroundColor:[UIColor whiteColor] ];
    
    mLoadEarlierMessagesButton.layer.cornerRadius = 3;
    
    [mLoadEarlierMessagesButton addTarget:self action:@selector(loadEarlierMessages) forControlEvents:UIControlEventTouchUpInside];
    
    [mLoadEarlierMessagesButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    [self.mTableHeaderView addSubview:mLoadEarlierMessagesButton];
    
    self.mMessageListArray = [NSMutableArray new];
    
    self.mSendMessageTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter message here" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // textfield right view
    
    self.mSendMessageTextField.rightViewMode = UITextFieldViewModeAlways;
    
    self.rightViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [self.rightViewButton setImage:[UIImage imageNamed:@"mobicom_ic_action_send_now2.png"] forState:UIControlStateNormal];
    
    [self.rightViewButton addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mSendMessageTextField setRightView:self.rightViewButton];
    
    [self.mTableView registerClass:[ALChatCell class] forCellReuseIdentifier:@"ChatCell"];
    
    [self.mTableView registerClass:[ALChatCell_Image class] forCellReuseIdentifier:@"ChatCell_Image"];
    // right attachment button
    
    UIBarButtonItem * theAttachmentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_action_attachment2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(attachmentAction)];
    
   self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:theAttachmentButton,refreshButton ,nil];
    
    // get msg count from db to handle load earlier rare scenario
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
    
    theRequest.predicate = [NSPredicate predicateWithFormat:@"contactId = %@",self.mLatestMessage.contactIds];
    
    self.mTotalCount = [theDbHandler.managedObjectContext countForFetchRequest:theRequest error:nil];
    
    NSLog(@"%lu",(unsigned long)self.mTotalCount);
    
    // image picker
    
    _mImagePicker = [[UIImagePickerController alloc] init];
    
    _mImagePicker.delegate = self;
    
    // fetch msgs from db
    
    [self loadChatView];
    
}

-(void)back:(id)sender {
    
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)refreshTable:(id)sender {
    
    NSLog(@"calling refresh from server....");
    //TODO: get the user name, devicekey String and make server call...
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    }
    
    if ([ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_BACKGROUND_COLOR])
        self.mTableView.backgroundColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_BACKGROUND_COLOR];
    else
        self.mTableView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.navColor;
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void) willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        
        if (self.mMessageListArray.count > 0) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateConversationTableNotification" object:self.mMessageListArray.lastObject];
        }
        
    }
}

#pragma mark IBActions

-(void) postMessage
{
    
    ALMessage * theMessage = [self getMessageToPost];
    
    [self.mMessageListArray addObject:theMessage];
    
    [self.mTableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self scrollTableViewToBottomWithAnimation:YES];
    });
    
    // save message to db
    
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_SMS * theSmsEntity = [self createSMSEntityForDBInsertionWithMessage:theMessage];
    
    [theDBHandler.managedObjectContext save:nil];
    
    NSDictionary * userInfo = [theMessage dictionary];
    
    [self.mSendMessageTextField setText:nil];
    
    self.mTotalCount = self.mTotalCount+1;
    
    self.startIndex = self.startIndex + 1;
    
    [ALMessageService sendMessagesForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
        
        if (error) {
            
            NSLog(@"%@",error);
            
            return ;
        }
        
        theMessage.sent = YES;
        
        theMessage.keyString = message;
        
        theSmsEntity.isSent = [NSNumber numberWithBool:YES];
        
        theSmsEntity.keyString = message;
        
        [theDBHandler.managedObjectContext save:nil];
        
        [self.mTableView reloadData];
        
    }];
    
}

-(void) loadEarlierMessages
{
    [self loadChatView];
    
}

#pragma mark tableview delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.mMessageListArray.count>0?self.mMessageListArray.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALMessage * theMessage = self.mMessageListArray[indexPath.row];
    
    if (theMessage.fileMetas.thumbnailUrl == nil ) { // textCell
        
        ALChatCell *theCell = (ALChatCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
        
        theCell.backgroundColor = [UIColor clearColor];
        
        BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[theMessage.createdAtTime doubleValue]/1000]];
        
        NSString * theDate = [NSString stringWithFormat:@"Via MT %@",[theMessage getCreatedAtTime:today]];
        
        theCell.mMessage = theMessage;
        
        theCell.tag = indexPath.row;
        
        CGSize theTextSize = [self getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:theCell.mMessageLabel.font.fontName fontSize:theCell.mMessageLabel.font.pointSize];
        
        CGSize theDateSize = [self getSizeForText:theDate maxWidth:150 font:theCell.mDateLabel.font.fontName fontSize:theCell.mDateLabel.font.pointSize];
        
        if ([theMessage.type isEqualToString:@"4"]) {
            
            theCell.mUserProfileImageView.frame = CGRectMake(8, 0, 45, 45);
            
            theCell.mUserProfileImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
            
            theCell.mMessageLabel.frame = CGRectMake(65 , 5, theTextSize.width, theTextSize.height);
            
            int imgVwWidth = theTextSize.width>150?theTextSize.width+20+14:150;
            
            int imgVwHeight = theTextSize.height+21>45?theTextSize.height+21+10:45;
            
            theCell.mBubleImageView.frame = CGRectMake(58 , 0, imgVwWidth , imgVwHeight);
            
            theCell.mDateLabel.frame = CGRectMake(65 , theCell.mMessageLabel.frame.origin.y+ theCell.mMessageLabel.frame.size.height + 3, theDateSize.width , 21);
            
            theCell.mDateLabel.textAlignment = NSTextAlignmentLeft;
            
            theCell.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
            
            theCell.mMessageStatusImageView.frame = CGRectMake(theCell.mDateLabel.frame.origin.x+theCell.mDateLabel.frame.size.width, theCell.mDateLabel.frame.origin.y, 20, 20);
            
        }
        else
        {
            theCell.mUserProfileImageView.frame = CGRectMake(self.view.frame.size.width-53, 0, 45, 45);
            
            theCell.mUserProfileImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
            
            int imgVwWidth = theTextSize.width>150?theTextSize.width+14:150;
            
            int imgVwHeight = theTextSize.height+21>45?theTextSize.height+21+10:45;
            
            theCell.mBubleImageView.frame = CGRectMake(self.view.frame.size.width - 58 - imgVwWidth , 0 ,imgVwWidth  ,imgVwHeight);
            
            theCell.mMessageLabel.frame = CGRectMake(theCell.mBubleImageView.frame.origin.x+8, 5, theTextSize.width, theTextSize.height);
            
            theCell.mDateLabel.frame = CGRectMake(theCell.mBubleImageView.frame.origin.x + 8, theCell.mMessageLabel.frame.origin.y + theCell.mMessageLabel.frame.size.height +3 , theDateSize.width, 21);
            
            theCell.mDateLabel.textAlignment = NSTextAlignmentLeft;
            
            theCell.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
            
            theCell.mMessageStatusImageView.frame = CGRectMake(theCell.mDateLabel.frame.origin.x+theCell.mDateLabel.frame.size.width+10, theCell.mDateLabel.frame.origin.y, 20, 20);
            
        }
        
        if ([theMessage.type isEqualToString:@"5"]) {
            
            if (theMessage.read) {
                
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_delivered.png"];
            }
            else if(theMessage.sendToDevice)
            {
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_delivered.png"];
                
            }
            else if(theMessage.sent)
            {
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_sent.png"];
                
            }
            else
            {
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_about.png"];
                
            }
        }
        
        theCell.mMessageLabel.text = theMessage.message;
        
        theCell.mDateLabel.text = theDate;
        
        [self.view layoutIfNeeded];
        
        return theCell;
        
        
    }
    else
    {
        ALChatCell_Image *theCell = (ALChatCell_Image *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell_Image"];
        
        theCell.tag = indexPath.row;
        
        theCell.delegate = self;
        
        theCell.backgroundColor = [UIColor clearColor];
        
        BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[theMessage.createdAtTime doubleValue]/1000]];
        
        NSString * theDate = [NSString stringWithFormat:@"Via MT %@",[theMessage getCreatedAtTime:today]];
        
        theCell.mMessage = theMessage;
        
        theCell.tag = indexPath.row;
        
        CGSize theDateSize = [self getSizeForText:theDate maxWidth:150 font:theCell.mDateLabel.font.fontName fontSize:theCell.mDateLabel.font.pointSize];
        
        if ([theMessage.type isEqualToString:@"4"]) {
            
            theCell.mUserProfileImageView.frame = CGRectMake(5, 5, 45, 45);
            
            theCell.mUserProfileImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
            
            theCell.mBubleImageView.frame = CGRectMake(theCell.mUserProfileImageView.frame.origin.x+ theCell.mUserProfileImageView.frame.size.width+5 , 5, self.view.frame.size.width-110, self.view.frame.size.width-110);
            
            theCell.mImageView.frame = CGRectMake(theCell.mBubleImageView.frame.origin.x + 5 , theCell.mBubleImageView.frame.origin.y + 15 , theCell.mBubleImageView.frame.size.width - 10 , theCell.mBubleImageView.frame.size.height - 40 );
            
            
            theCell.mDateLabel.frame = CGRectMake(theCell.mBubleImageView.frame.origin.x + 5 , theCell.mImageView.frame.origin.y + theCell.mImageView.frame.size.height + 5, theDateSize.width , 20);
            
            theCell.mDateLabel.textAlignment = NSTextAlignmentLeft;
            
            theCell.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
            
            theCell.mMessageStatusImageView.frame = CGRectMake(theCell.mDateLabel.frame.origin.x+theCell.mDateLabel.frame.size.width, theCell.mDateLabel.frame.origin.y, 20, 20);
            
            if (theMessage.storeOnDevice == NO) {
                
                theCell.mDowloadRetryButton.alpha = 1;
        
                [theCell.mDowloadRetryButton setTitle:[theMessage.fileMetas getTheSize] forState:UIControlStateNormal];
                
                [theCell.mDowloadRetryButton setImage:[UIImage imageNamed:@"ic_download.png"] forState:UIControlStateNormal];
                
            }
            else
            {
                theCell.mDowloadRetryButton.alpha = 0;
            }
            
            if (theMessage.inProgress == YES) {
               theCell.progresLabel.alpha = 1;
               theCell.mDowloadRetryButton.alpha = 0;
            }else {
                theCell.progresLabel.alpha = 0;
            }
            
        }
        else
        {
            
            theCell.mUserProfileImageView.frame = CGRectMake(self.view.frame.size.width-50, 5, 45, 45);
            
            theCell.mUserProfileImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
            
            theCell.mBubleImageView.frame = CGRectMake(self.view.frame.size.width - theCell.mUserProfileImageView.frame.origin.x + 5 , 5 ,self.view.frame.size.width-110, self.view.frame.size.width-110);
            
            theCell.mImageView.frame = CGRectMake(theCell.mBubleImageView.frame.origin.x + 5 , theCell.mBubleImageView.frame.origin.y+15 ,theCell.mBubleImageView.frame.size.width - 10 , theCell.mBubleImageView.frame.size.height - 40);
            
            theCell.mDateLabel.frame = CGRectMake(theCell.mBubleImageView.frame.origin.x + 5, theCell.mImageView.frame.origin.y + theCell.mImageView.frame.size.height + 5 , theDateSize.width, 21);
            
            theCell.mDateLabel.textAlignment = NSTextAlignmentLeft;
            
            theCell.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
            
            theCell.mMessageStatusImageView.frame = CGRectMake(theCell.mDateLabel.frame.origin.x+theCell.mDateLabel.frame.size.width+10, theCell.mDateLabel.frame.origin.y, 20, 20);
            
            
            
            if (theMessage.isUploadFailed == NO) {
                
                
                theCell.mDowloadRetryButton.alpha = 0;
            }
            else
            {
                theCell.mDowloadRetryButton.alpha = 1;
                
                [theCell.mDowloadRetryButton setTitle:[theMessage.fileMetas getTheSize] forState:UIControlStateNormal];
                
                [theCell.mDowloadRetryButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
                
            }
            
            if (theMessage.inProgress == YES) {
                theCell.progresLabel.alpha = 1;
                
            }else {
                theCell.progresLabel.alpha = 0;
            }
            
        }
        
        theCell.mDowloadRetryButton.frame = CGRectMake(theCell.mImageView.frame.origin.x + theCell.mImageView.frame.size.width/2.0 - 50 , theCell.mImageView.frame.origin.y + theCell.mImageView.frame.size.height/2.0 - 15 , 100, 30);
        
        if ([theMessage.type isEqualToString:@"5"]) {
            
            if (theMessage.read) {
                
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_delivered.png"];
            }
            else if(theMessage.sendToDevice)
            {
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_delivered.png"];
                
            }
            else if(theMessage.sent)
            {
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_sent.png"];
                
            }
            else
            {
                theCell.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_about.png"];
                
            }
        }
        
        theCell.mDateLabel.text = theDate;
        
        NSURL * theUrl = nil ;
        
        if ([theMessage.fileMetas.thumbnailUrl containsString:@"local"]) {
            
            NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString * filePath = [docDir stringByAppendingPathComponent:theMessage.fileMetas.thumbnailUrl];
            
            theUrl = [NSURL fileURLWithPath:filePath];
        }
        else
        {
            theUrl = [NSURL URLWithString:theMessage.fileMetas.thumbnailUrl];
            
        }
        
        [theCell.mImageView sd_setImageWithURL:theUrl];
        
        [self.view layoutIfNeeded];
        
        return theCell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALMessage * theMessage = self.mMessageListArray[indexPath.row];
    
    if (theMessage.fileMetas.thumbnailUrl == nil) {
        
        CGSize theTextSize = [self getSizeForText:theMessage.message maxWidth:self.view.frame.size.width-115 font:@"Helvetica-Bold" fontSize:15];
        
        int extraSpace = 40 ;
        
        return theTextSize.height+21+extraSpace;
        
    }
    else
    {
        return self.view.frame.size.width-110+40;
    }
}

#pragma mark helper methods

-(ALMessage *) getMessageToPost
{
    ALMessage * theMessage = [ALMessage new];
    
    theMessage.type = @"5";
    
    theMessage.contactIds = self.mLatestMessage.contactIds;
    
    theMessage.to = self.mLatestMessage.to;
        
    theMessage.createdAtTime = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]*1000];
    
    theMessage.deviceKeyString = @"agpzfmFwcGxvemljciYLEgZTdVVzZXIYgICAgK_hmQoMCxIGRGV2aWNlGICAgICAgIAKDA";
    
    theMessage.message = self.mSendMessageTextField.text;
    
    theMessage.sendToDevice = NO;
    
    theMessage.sent = NO;
    
    theMessage.shared = NO;
    
    theMessage.fileMetas = nil;
    
    theMessage.read = NO;
    
    theMessage.storeOnDevice = NO;
    
    theMessage.keyString = @"test keystring";
    
    theMessage.fileMetaKeyStrings = @[];
    
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

- (CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize {
    
    CGSize constraintSize;
    
    constraintSize.height = MAXFLOAT;
    
    constraintSize.width = width;
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    
    CGSize stringSize = frame.size;
    
    return stringSize;
}

-(void) scrollTableViewToBottomWithAnimation:(BOOL) animated
{
    
    if (self.mTableView.contentSize.height > self.mTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.mTableView.contentSize.height - self.mTableView.frame.size.height);
        
        [self.mTableView setContentOffset:offset animated:animated];
    }
}

#pragma mark keyboard notification

-(void) keyBoardWillShow:(NSNotification *) notification
{
    
    NSDictionary * theDictionary = notification.userInfo;
    
    NSString * theAnimationDuration = [theDictionary valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect keyboardEndFrame = [(NSValue *)[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.mSendTextFieldBottomConstraint.constant = self.view.frame.size.height - keyboardEndFrame.origin.y;
    
    [UIView animateWithDuration:theAnimationDuration.doubleValue animations:^{
        
        [self.view layoutIfNeeded];
        
        [self scrollTableViewToBottomWithAnimation:YES];
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            [self scrollTableViewToBottomWithAnimation:YES];
            
        }
    }];
}


-(void) keyBoardWillHide:(NSNotification *) notification
{
    
    NSDictionary * theDictionary = notification.userInfo;
    
    NSString * theAnimationDuration = [theDictionary valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    self.mSendTextFieldBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:theAnimationDuration.doubleValue animations:^{
        
        [self.view layoutIfNeeded];
        
    }];
}

#pragma mark textfield delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark tap gesture

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    
    if ([self.mSendMessageTextField isFirstResponder]) {
        
        [self.mSendMessageTextField resignFirstResponder];
    }
}

#pragma mark helper methods

-(void) loadChatView
{
    
    BOOL isLoadEarlierTapped = self.mMessageListArray.count == 0 ? NO : YES ;
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
    
    [theRequest setFetchLimit:self.rp];
    
    theRequest.predicate = [NSPredicate predicateWithFormat:@"contactId = %@",self.mLatestMessage.contactIds];
    
    [theRequest setFetchOffset:self.startIndex];
    
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    
    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    
    for (DB_SMS * theEntity in theArray) {
        
        ALMessage * theMessage = [self createMessageForSMSEntity:theEntity];
        
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

-(DB_SMS *) createSMSEntityForDBInsertionWithMessage:(ALMessage *) theMessage
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_SMS * theSmsEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_SMS" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    theSmsEntity.contactId = theMessage.contactIds;
    
    theSmsEntity.createdAt = [NSNumber numberWithInteger:theMessage.createdAtTime.integerValue];
    
    theSmsEntity.deviceKeyString = theMessage.deviceKeyString;
    
    theSmsEntity.isRead = [NSNumber numberWithBool:theMessage.read];
    
    theSmsEntity.isSent = [NSNumber numberWithBool:theMessage.sent];
    
    theSmsEntity.isSentToDevice = [NSNumber numberWithBool:theMessage.sendToDevice];
    
    theSmsEntity.isShared = [NSNumber numberWithBool:theMessage.shared];
    
    theSmsEntity.isStoredOnDevice = [NSNumber numberWithBool:theMessage.storeOnDevice];
    
    theSmsEntity.keyString = theMessage.keyString;
    
    theSmsEntity.messageText = theMessage.message;
    
    theSmsEntity.suUserKeyString = theMessage.suUserKeyString;
    
    theSmsEntity.to = theMessage.to;
    
    theSmsEntity.type = theMessage.type;
    
    theSmsEntity.filePath = theMessage.imageFilePath;
    
    return theSmsEntity;
}

-(DB_FileMetaInfo *) createFileMetaInfoEntityForDBInsertionWithMessage:(ALFileMetaInfo *) fileInfo
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_FileMetaInfo * fileMetaInfo = [NSEntityDescription insertNewObjectForEntityForName:@"DB_FileMetaInfo" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    fileMetaInfo.blobKeyString = fileInfo.blobKeyString;
    
    fileMetaInfo.contentType = fileInfo.contentType;
    
    fileMetaInfo.createdAtTime = fileInfo.createdAtTime;
    
    fileMetaInfo.keyString = fileInfo.keyString;
    
    fileMetaInfo.name = fileInfo.name;
    
    fileMetaInfo.size = fileInfo.size;
    
    fileMetaInfo.suUserKeyString = fileInfo.suUserKeyString;
    
    fileMetaInfo.thumbnailUrl = fileInfo.thumbnailUrl;
    
    return fileMetaInfo;
}

-(ALMessage *) createMessageForSMSEntity:(DB_SMS *) theEntity
{
    ALMessage * theMessage = [ALMessage new];
    
    theMessage.keyString = theEntity.keyString;
    
    theMessage.deviceKeyString = theEntity.deviceKeyString;
    
    theMessage.suUserKeyString = theEntity.suUserKeyString;
    
    theMessage.to = theEntity.to;
    
    theMessage.message = theEntity.messageText;
    
    theMessage.sent = theEntity.isSent.boolValue;
    
    theMessage.sendToDevice = theEntity.isSentToDevice.boolValue;
    
    theMessage.shared = theEntity.isShared.boolValue;
    
    theMessage.createdAtTime = [NSString stringWithFormat:@"%@",theEntity.createdAt];
    
    theMessage.type = theEntity.type;
    
    theMessage.contactIds = theEntity.contactId;
    
    theMessage.storeOnDevice = theEntity.isStoredOnDevice.boolValue;
    
    theMessage.read = theEntity.isRead;
    
    theMessage.imageFilePath = theEntity.filePath;
    
    // file meta info
    
    ALFileMetaInfo * theFileMeta = [ALFileMetaInfo new];
    
    theFileMeta.blobKeyString = theEntity.fileMetaInfo.blobKeyString;
    
    theFileMeta.contentType = theEntity.fileMetaInfo.contentType;
    
    theFileMeta.createdAtTime = theEntity.fileMetaInfo.createdAtTime;
    
    theFileMeta.keyString = theEntity.fileMetaInfo.keyString;
    
    theFileMeta.name = theEntity.fileMetaInfo.name;
    
    theFileMeta.size = theEntity.fileMetaInfo.size;
    
    theFileMeta.suUserKeyString = theEntity.fileMetaInfo.suUserKeyString;
    
    theFileMeta.thumbnailUrl = theEntity.fileMetaInfo.thumbnailUrl;
    
    theMessage.fileMetas = theFileMeta;
    
    return theMessage;
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

-(void)dowloadRetryButtonActionDelegate:(int)index andMessage:(ALMessage *)message
{
    
    ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    imageCell.progresLabel.alpha = 1;
    
    imageCell.mMessage.fileMetas.progressValue = 0;
    
    imageCell.mDowloadRetryButton.alpha = 0;
    
    message.inProgress = YES;
    
    NSMutableArray * theCurrentConnectionsArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
    
    NSArray * theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.fileMetas.keyString]];
    
    if ([message.type isEqualToString:@"5"]) { // retry or cancel
        
        if (theFiletredArray.count == 0) { // retry
            
            message.isUploadFailed = NO;
                        
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
            
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.thumbnailUrl == %@",message.fileMetas.thumbnailUrl];
            
            NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            DB_SMS  * smsEntity = theArray[0];
            
            smsEntity.inProgress = [NSNumber numberWithBool:YES];
            
            smsEntity.isUploadFailed = [NSNumber numberWithBool:NO];
            
            [[ALDBHandler sharedInstance].managedObjectContext save:nil];
            
            DB_FileMetaInfo *fileMetaInfo = smsEntity.fileMetaInfo;
            
            [self uploadImage:@[message,fileMetaInfo]];
        }
    }
    else // download or cancel
    {
        if (theFiletredArray.count == 0) { // download
            
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
            
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.keyString == %@",message.fileMetas.keyString];
            
            NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            DB_SMS  * smsEntity = theArray[0];
            
            smsEntity.inProgress = [NSNumber numberWithBool:YES];
            
            [[ALDBHandler sharedInstance].managedObjectContext save:nil];
            
            [self processImageDownloadforMessage:message withTag:index];
            
        }
    }
}

-(void)stopDownloadForIndex:(int)index andMessage:(ALMessage *)message {
    
    ALChatCell_Image *imageCell = (ALChatCell_Image *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    imageCell.progresLabel.alpha = 0;
    
    imageCell.mDowloadRetryButton.alpha = 1;
    
    message.inProgress = NO;
    
    NSMutableArray * theCurrentConnectionsArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
    
    NSArray * theFiletredArray = nil;
    
    if ([message.type isEqualToString:@"5"]) { // retry or cancel
        
        theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"connectionTag == %d", index]];
        
        if (theFiletredArray.count != 0) { // cancel
            
            message.isUploadFailed = YES;
            
            [imageCell.mDowloadRetryButton setTitle:[message.fileMetas getTheSize] forState:UIControlStateNormal];
            
            [imageCell.mDowloadRetryButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
            
            ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
            
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
            
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.thumbnailUrl == %@",message.fileMetas.thumbnailUrl];
            
            NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            DB_SMS  * smsEntity = theArray[0];
            
            smsEntity.isUploadFailed = [NSNumber numberWithBool:YES];
            
            smsEntity.inProgress = [NSNumber numberWithBool:NO];
            
            [theDBHandler.managedObjectContext save:nil];
            
            [self cancelImageDownloadForMessage:message withtag:index];
        }
        
    }
    else // download or cancel
    {
        theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.fileMetas.keyString]];
        
        if (theFiletredArray.count != 0) { // cancel
            
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
            
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.keyString == %@",message.fileMetas.keyString];
            
            NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            DB_SMS  * smsEntity = theArray[0];
            
            smsEntity.inProgress = [NSNumber numberWithBool:YES];
            
            [[ALDBHandler sharedInstance].managedObjectContext save:nil];
            
            [self cancelImageDownloadForMessage:message withtag:index];
            
        }
    }
}

-(void) processImageDownloadforMessage:(ALMessage *) message withTag:(int) tag
{
    
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",APPLOGIC_IMAGEDOWNLOAD_BASEURL,message.fileMetas.keyString];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:urlString paramString:nil];
    
    ALConnection * connection = [[ALConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    connection.keystring = message.fileMetas.keyString;
    
    connection.connectionTag = tag;
    
    connection.connectionType = @"Image Downloading";
    
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
}

-(void) cancelImageDownloadForMessage:(ALMessage *) message withtag:(int) tag
{
    
    // cancel connection
    
    NSMutableArray * theConnectionArray =  [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
    
    ALConnection * connection = [[theConnectionArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"connectionTag == %d",tag]] objectAtIndex:0];
    
    [connection cancel];
    
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    
}

-(void) proessUploadImageForMessage:(ALMessage *)message databaseObj:(DB_FileMetaInfo *)fileMetaInfo uploadURL:(NSString *)uploadURL  withTag:(NSInteger)tag {
    
    NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString * timestamp = message.imageFilePath;
    
    NSString * filePath = [docDirPath stringByAppendingPathComponent:timestamp];
    
    NSMutableURLRequest * request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        //Create boundary, it can be anything
        NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // post body
        NSMutableData *body = [NSMutableData data];
        
        //Populate a dictionary with all the regular values you would like to send.
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        
        // add params (all params are strings)
        for (NSString *param in parameters) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSString *FileParamConstant = @"files[]";
        
        
        NSData *imageData = [[NSData alloc]initWithContentsOfFile:filePath];
        
        NSLog(@"%f",imageData.length/1024.0);
        
        //Assuming data is not nil we add this to the multipart form
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type:image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // setting the body of the post to the request
        [request setHTTPBody:body];
        
        // set URL
        [request setURL:[NSURL URLWithString:uploadURL]];
        
        ALConnection * connection = [[ALConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
        connection.connectionTag = (int)tag;
        connection.connectionType = @"Image Posting";
        connection.fileMetaInfo = fileMetaInfo;
        
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
    }
}

#pragma mark connection delegates

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data
{
    
    [connection.mData appendData:data];
    
    
    if ([connection.connectionType isEqualToString:@"Image Posting"]) {
        
    }else {
    NSIndexPath *path = [NSIndexPath indexPathForRow:connection.connectionTag inSection:0];
    
    ALChatCell_Image *cell = (ALChatCell_Image *)[_mTableView cellForRowAtIndexPath:path];
        
    cell.mMessage.fileMetas.progressValue = [self bytesConvertsToDegree:[cell.mMessage.fileMetas.size floatValue] comingBytes:(CGFloat)connection.mData.length];
         NSLog(@"%lu %f",(unsigned long)connection.mData.length,[cell.mMessage.fileMetas.size floatValue]);
    }
    
   
    
}

-(CGFloat)bytesConvertsToDegree:(CGFloat)totalBytesExpectedToWrite comingBytes:(CGFloat)totalBytesWritten {
    
    CGFloat  totalBytes = totalBytesExpectedToWrite;
    
    CGFloat writtenBytes = totalBytesWritten;
    
    CGFloat divergence = totalBytes/360;
    
    CGFloat degree = writtenBytes/divergence;
    
    return degree;
}


-(void)connectionDidFinishLoading:(ALConnection *)connection {
    
    if ([connection.connectionType isEqualToString:@"Image Posting"]) {
        
        NSLog(@"%@",[[NSString alloc] initWithData:connection.mData encoding:NSUTF8StringEncoding]);
        
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
        
        NSError * theJsonError = nil;
        
        NSDictionary *theJson = [NSJSONSerialization JSONObjectWithData:connection.mData options:NSJSONReadingMutableLeaves error:&theJsonError];
        
        NSDictionary *fileInfo = [theJson objectForKey:@"fileMeta"];
        
        ALMessage *theMessage = [self.mMessageListArray objectAtIndex:connection.connectionTag];
        NSLog(@"%@",[fileInfo objectForKey:@"blobKeyString"]);
        NSString *localFileURL = theMessage.fileMetas.thumbnailUrl;
        theMessage.fileMetas.blobKeyString = [fileInfo objectForKey:@"blobKeyString"];
        theMessage.fileMetas.contentType = [fileInfo objectForKey:@"contentType"];
        theMessage.fileMetas.createdAtTime = [fileInfo objectForKey:@"createdAtTime"];
        theMessage.fileMetas.keyString = [fileInfo objectForKey:@"keyString"];
        theMessage.fileMetas.name = [fileInfo objectForKey:@"name"];
        theMessage.fileMetas.size = [fileInfo objectForKey:@"size"];
        theMessage.fileMetas.suUserKeyString = [fileInfo objectForKey:@"suUserKeyString"];
        theMessage.fileMetas.thumbnailUrl = [fileInfo objectForKey:@"thumbnailUrl"];
        theMessage.fileMetaKeyStrings = @[theMessage.fileMetas.keyString];
        
        ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
        
        DB_FileMetaInfo * theFileMetaInfo = connection.fileMetaInfo;
        
        theFileMetaInfo.blobKeyString = theMessage.fileMetas.blobKeyString;
        theFileMetaInfo.contentType = theMessage.fileMetas.contentType;
        theFileMetaInfo.createdAtTime = theMessage.fileMetas.createdAtTime;
        theFileMetaInfo.keyString = theMessage.fileMetas.keyString;
        theFileMetaInfo.name = theMessage.fileMetas.name;
        theFileMetaInfo.size = theMessage.fileMetas.size;
        theFileMetaInfo.suUserKeyString = theMessage.fileMetas.suUserKeyString;

        
        [theDBHandler.managedObjectContext save:nil];
        
        NSDictionary * userInfo = [theMessage dictionary];
        
        [ALMessageService sendMessagesForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
            
            if (error) {
                
                NSLog(@"%@",error);
                
                return ;
            }
            
            theMessage.sent = YES;
            
            theMessage.keyString = message;
            
            theMessage.fileMetas.thumbnailUrl = localFileURL;
            
            theMessage.inProgress = NO;
            
            theMessage.isUploadFailed = NO;
            
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
            
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.keyString == %@",theMessage.fileMetas.keyString];
            
            NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            DB_SMS  * smsEntity = theArray[0];
            
            smsEntity.isSent = [NSNumber numberWithBool:YES];
            
            smsEntity.keyString = message;
            
            smsEntity.inProgress = [NSNumber numberWithBool:NO];
            
            smsEntity.isUploadFailed = [NSNumber numberWithBool:NO];
            
            [theDBHandler.managedObjectContext save:nil];
            
            [self.mTableView reloadData];
            
        }];
        
    }else {
        
        // remove connection
        
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
        
        // save file to doc
        
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString * filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.local",connection.keystring]];
        
        [connection.mData writeToFile:filePath atomically:YES];
        
        
        // update db
        
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.keyString == %@",connection.keystring];
        
        NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        DB_SMS  * smsEntity = theArray[0];
        
        smsEntity.isStoredOnDevice = [NSNumber numberWithBool:YES];
        
        smsEntity.inProgress = [NSNumber numberWithBool:NO];
        
        smsEntity.fileMetaInfo.thumbnailUrl = [NSString stringWithFormat:@"%@.local",connection.keystring];
        
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        
        
        // reload tableview
        
        NSArray * filteredArray = [self.mMessageListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fileMetas.keyString == %@",connection.keystring]];
        
        if (filteredArray.count > 0) {
            
            ALMessage * message = filteredArray[0];
            
            message.storeOnDevice = YES;
            
            message.inProgress = NO;
            
            message.fileMetas.thumbnailUrl = [NSString stringWithFormat:@"%@.local",connection.keystring];
        }
        [self.mTableView reloadData];
    }
}

-(void)connection:(ALConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
}

-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"bytesWritten %ld",(long)bytesWritten);
    NSLog(@"totalBytesWritten %ld",(long)totalBytesWritten);
    NSLog(@"totalBytesExpectedToWrite %ld",(long)totalBytesExpectedToWrite);
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:connection.connectionTag inSection:0];
    
    ALChatCell_Image *cell = (ALChatCell_Image *)[_mTableView cellForRowAtIndexPath:path];
    
    cell.mMessage.fileMetas.progressValue = [self bytesConvertsToDegree:totalBytesExpectedToWrite comingBytes:totalBytesWritten];
    NSLog(@"%lu %f",(unsigned long)connection.mData.length,[cell.mMessage.fileMetas.size floatValue]);
    
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
    
    NSString * filePath = [self saveImageToDocDirectory:image];
    
    // create message object
    
    ALMessage * theMessage = [self getMessageToPost];
    
    theMessage.fileMetas = [self getFileMetaInfo];
    
    theMessage.imageFilePath = filePath.lastPathComponent;
    
    NSData *imageSize = [NSData dataWithContentsOfFile:filePath];
    
    theMessage.fileMetas.size = [NSString stringWithFormat:@"%lu",(unsigned long)imageSize.length];
    
    theMessage.fileMetas.thumbnailUrl = filePath.lastPathComponent;
    
    // save msg to db
    
    [self.mMessageListArray addObject:theMessage];
    
    [self.mTableView reloadData];
    
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_SMS * theSmsEntity = [self createSMSEntityForDBInsertionWithMessage:theMessage];
    
    DB_FileMetaInfo *theFileMetaInfo = [self createFileMetaInfoEntityForDBInsertionWithMessage:theMessage.fileMetas];
    
    theSmsEntity.fileMetaInfo = theFileMetaInfo;
    
    [theDBHandler.managedObjectContext save:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        [self scrollTableViewToBottomWithAnimation:YES];
//        
//        [self performSelector:@selector(uploadImage:)
//                   withObject:@[theMessage,theFileMetaInfo]
//                   afterDelay:1];
        
        [UIView animateWithDuration:.50 animations:^{
            [self scrollTableViewToBottomWithAnimation:YES];
        } completion:^(BOOL finished) {
            [self uploadImage:@[theMessage,theFileMetaInfo]];
        }];
    });

    // post message
    
}

-(void)uploadImage:(NSArray *)objects {
    
    ALMessage *theMessage = (ALMessage *)[objects firstObject];
    
    DB_FileMetaInfo *theFileMetaInfo = (DB_FileMetaInfo *)[objects lastObject];
    
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
                [self uploadImage:objects];
            }];
            return;
        }
        
        imageCell.progresLabel.alpha = 1;
        
        imageCell.mMessage.fileMetas.progressValue = 0;
        
        imageCell.mDowloadRetryButton.alpha = 0;
        
        imageCell.mMessage.inProgress = YES;
        
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_SMS"];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fileMetaInfo.thumbnailUrl == %@",imageCell.mMessage.fileMetas.thumbnailUrl];
        
        NSArray * theArray = [[ALDBHandler sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        DB_SMS  * smsEntity = theArray[0];
        
        smsEntity.inProgress = [NSNumber numberWithBool:YES];
        
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        
        // post image
        
        [ALMessageService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
            
            if (error) {
                
                NSLog(@"%@",error);
                
                return ;
            }
            
            NSInteger tag = [self.mMessageListArray indexOfObject:theMessage];
            
            [self proessUploadImageForMessage:theMessage databaseObj:theFileMetaInfo uploadURL:message withTag:tag];
            
        }];
    }
}

#pragma mark actionsheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"photo library"])
        [self openGallery];
        
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"take photo"])
        [self openCamera];
}

-(void) showActionSheet
{
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"take photo",@"photo library", nil];
    
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

-(NSString *) saveImageToDocDirectory:(UIImage *) image
{
    NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString * timestamp = [NSString stringWithFormat:@"%f.local",[[NSDate date] timeIntervalSince1970]];
    
    NSString * filePath = [docDirPath stringByAppendingPathComponent:timestamp];
    
    NSData * imageData = UIImageJPEGRepresentation(image, 1);
    
    [imageData writeToFile:filePath atomically:YES];
    
    return filePath;
    
}

@end
