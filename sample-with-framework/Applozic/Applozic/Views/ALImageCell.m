//
//  ALImageCell.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define DATE_LABEL_SIZE 12
#define MESSAGE_TEXT_SIZE 14

#import "ALImageCell.h"
#import "UIImageView+WebCache.h"
#import "ALDBHandler.h"
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"
#import "ALMessageService.h"
#import "ALMessageDBService.h"
#import "ALUtilityClass.h"
#import "ALColorUtility.h"
#import "ALMessage.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALDataNetworkConnection.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"

@implementation ALImageCell
{
    CGFloat msgFrameHeight;
    NSURL * theUrl;
}

UIViewController * modalCon;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        
        self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2.0 - 50 , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height/2.0 - 20 , 100, 40);
        
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageFullScreen:)];
        tapper.numberOfTapsRequired = 1;
        [self.mImageView addGestureRecognizer:tapper];
        [self.contentView addSubview:self.mImageView];
        
        [self.mDowloadRetryButton addTarget:self action:@selector(dowloadRetryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
    
}

-(instancetype)populateCell:(ALMessage *)alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];
    
    self.mUserProfileImageView.alpha = 1;
    self.progresLabel.alpha = 0;

    [self.mDowloadRetryButton setHidden:NO];
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact * alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    
    NSString * receiverName = [alContact getDisplayName];
    
    self.mMessage = alMessage;
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width - 130 font:self.imageWithText.font.fontName fontSize:self.imageWithText.font.pointSize];
    
    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.imageWithText setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    
    if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT]) { //@"4" //Recieved Message
        
        [self.contentView bringSubviewToFront:self.mChannelMemberName];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 45, 45);
        }
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13 , 0, viewSize.width - 120, viewSize.width - 120);
        
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;
        
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y + 5 , self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 10 );
        
        
        if(alMessage.getGroupId)
        {
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13 , 0, viewSize.width - 120, viewSize.width - 100);
            
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                                       self.mBubleImageView.frame.origin.y + 5,
                                                       self.mBubleImageView.frame.size.width + 30, 20);
            
            self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                               self.mChannelMemberName.frame.origin.y + self.mChannelMemberName.frame.size.height + 5,
                                               self.mBubleImageView.frame.size.width - 10 ,
                                               self.mBubleImageView.frame.size.height - self.mChannelMemberName.frame.size.height - 15);
            
        }
        
        [self setupProgress];
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        if(alMessage.message.length > 0)
        {
            self.imageWithText.textColor = [UIColor grayColor];
            self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13, 0, viewSize.width - 120, (viewSize.width - 120) + theTextSize.height + 20);
            
            self.imageWithText.frame = CGRectMake(self.mImageView.frame.origin.x, self.mBubleImageView.frame.origin.y + self.mImageView.frame.size.height + 10, self.mImageView.frame.size.width, theTextSize.height);
            
            [self.imageWithText setHidden:NO];
            
            [self.contentView bringSubviewToFront:self.mDateLabel];
            [self.contentView bringSubviewToFront:self.mMessageStatusImageView];
        }
        else
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.imageWithText setHidden:YES];
        }
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x,
                                           self.mBubleImageView.frame.origin.y +
                                           self.mBubleImageView.frame.size.height,
                                           theDateSize.width,
                                           21);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        
        if (alMessage.imageFilePath == NULL)
        {
            NSLog(@" file path not found making download button visible ....ALImageCell");
            
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
            
        }
        else
        {
            self.mDowloadRetryButton.alpha = 0;
        }
        if (alMessage.inProgress == YES)
        {
            NSLog(@" In progress making download button invisible ....");
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }
        
    }
    else
    { //Sent Message
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - 50, 5, 0, 45);
        
        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), 0, viewSize.width - 120, viewSize.width - 120);
        
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y + 5 ,self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 10);
        
        [self.mMessageStatusImageView setHidden:NO];
        
        if(alMessage.message.length > 0)
        {
            [self.imageWithText setHidden:NO];
            self.imageWithText.backgroundColor = [UIColor clearColor];
            self.imageWithText.textColor = [UIColor whiteColor];
            self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), 0, viewSize.width - 120, (viewSize.width - 120) + theTextSize.height + 20);
            
            self.imageWithText.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5, self.mBubleImageView.frame.origin.y + self.mImageView.frame.size.height + 10, self.mImageView.frame.size.width, theTextSize.height);
            
            [self.contentView bringSubviewToFront:self.mDateLabel];
            [self.contentView bringSubviewToFront:self.mMessageStatusImageView];
            
        }
        else
        {
            [self.imageWithText setHidden:YES];
            
        }
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - 20, self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, 21);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        [self setupProgress];
        
        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            NSLog(@"calling you progress label....");
        }
        else if( !alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
            
        }
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
        
    }
    
    self.mDowloadRetryButton.frame = CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 45 , self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 20 , 90, 40);
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]) {
        
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue) {
            case DELIVERED_AND_READ :{
                imageName = @"ic_action_read.png";
            }break;
            case DELIVERED:{
                imageName = @"ic_action_message_delivered.png";
            }break;
            case SENT:{
                imageName = @"ic_action_message_sent.png";
            }break;
            default:{
                imageName = @"ic_action_about.png";
            }break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    self.imageWithText.text = alMessage.message;
    self.mDateLabel.text = theDate;
    
    theUrl = nil;

    if (alMessage.imageFilePath != NULL)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        theUrl = [NSURL fileURLWithPath:filePath];
    }
    else
    {
        theUrl = [NSURL URLWithString:alMessage.fileMeta.thumbnailUrl];
    }
    
    [self.mImageView sd_setImageWithURL:theUrl];
    return self;
    
}

#pragma mark - KAProgressLabel Delegate Methods -

-(void)cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void) dowloadRetryButtonAction
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

- (void)dealloc
{
    if(super.mMessage.fileMeta)
    {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

-(void)setMMessage:(ALMessage *)mMessage
{
    //TODO: error ...observer shoud be there...
    if(super.mMessage.fileMeta)
    {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
    
    super.mMessage = mMessage;
    [super.mMessage.fileMeta addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
    // NSLog(@"##observer is called....%f",self.progresLabel.endDegree );
}

-(void)imageFullScreen:(UITapGestureRecognizer*)sender
{
    modalCon = [[UIViewController alloc] init];
    modalCon.view.backgroundColor=[UIColor blackColor];
    modalCon.view.userInteractionEnabled=YES;
    
    UIImageView *imageViewNew = [[UIImageView alloc] initWithFrame:modalCon.view.frame];
    imageViewNew.contentMode = UIViewContentModeScaleAspectFit;
    imageViewNew.image = self.mImageView.image;
    [modalCon.view addSubview:imageViewNew];
    
    UITapGestureRecognizer *modalTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalView:)];
    [modalCon.view addGestureRecognizer:modalTap];
    [self.delegate showFullScreen:modalCon];

    return;
}

-(void)setupProgress
{
    self.progresLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 25, self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 25, 50, 50)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview:self.progresLabel];
    
}

-(void)dismissModalView:(UITapGestureRecognizer*)gesture
{
    [modalCon dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (action == @selector(delete:)|| action == @selector(msgInfo:));
    }
    
    return (action == @selector(delete:));
}

-(void) delete:(id)sender
{
    //UI
    NSLog(@"message to deleteUI %@",self.mMessage.message);
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString* string,NSError* error) {
        
        if(!error )
        {
            NSLog(@"No Error");
        }
        else{
            NSLog(@"some error");
        }
        
    }];
}

- (void)msgInfo:(id)sender
{
    [self.delegate showAnimationForMsgInfo];
    UIStoryboard* storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *launchChat = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    
    launchChat.contentURL = theUrl;
    [launchChat setMessage:self.mMessage andHeaderHeight:msgFrameHeight  withCompletionHandler:^(NSError *error) {
        
        if(!error)
        {
            [self.delegate loadViewForMedia:launchChat];
        }
    }];
}

@end
