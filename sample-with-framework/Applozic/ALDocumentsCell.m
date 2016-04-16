//
//  ALDocumentsCell.m
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"
#define DATE_LABEL_SIZE 12

#import "ALDocumentsCell.h"
#import "ALMessage.h"
#import "ALContactDBService.h"
#import "ALColorUtility.h"
#import "UIImageView+WebCache.h"
#import "KAProgressLabel.h"
#import "ALUtilityClass.h"
#import "ALMessageService.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"

@implementation ALDocumentsCell
{
    CGFloat msgFrameHeight;
    NSURL *fileSourceURL;
    UIViewController *viewController;
}

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        [self.mDowloadRetryButton addTarget:self action:@selector(downloadRetry) forControlEvents:UIControlEventTouchUpInside];
        [self.mDowloadRetryButton setBackgroundColor:[UIColor clearColor]];
        
        self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suggestionAction)];
        self.tapper.numberOfTapsRequired = 1;
        
        [self.mImageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.mImageView];
        
        self.documentName = [[UILabel alloc] init];
        [self.documentName setBackgroundColor:[UIColor clearColor]];
        [self.documentName setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        [self.documentName setNumberOfLines:4];
        [self.contentView addSubview:self.documentName];
        
        self.downloadRetryView = [UIView new];
        [self.downloadRetryView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [self.contentView addSubview:self.downloadRetryView];
        self.downloadRetryView.layer.cornerRadius = 5;
        self.downloadRetryView.layer.masksToBounds = YES;
        
        self.sizeLabel = [UILabel new];
        [self.sizeLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.sizeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.sizeLabel setTextColor:[UIColor clearColor]];
        [self.sizeLabel setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.sizeLabel];
        
    }
    return self;
}

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    
    self.progresLabel.alpha = 0;
    [self.mNameLabel setHidden:YES];
    [self setMMessage:alMessage];
    [self.mBubleImageView setUserInteractionEnabled:NO];
    [self.mImageView setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    [self.mChannelMemberName setHidden:YES];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    NSString *receiverName = alContact.displayName? alContact.displayName: alMessage.to;
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        [self.mUserProfileImageView setFrame:CGRectMake(5, 0, 45, 45)];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.mUserProfileImageView setFrame:CGRectMake(5, 0, 0, 45)];
        }
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
        [self.documentName setTextColor:[UIColor grayColor]];
        
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + 13,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - 120, 80)];
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x, self.mBubleImageView.frame.origin.y + 10, 60, 60)];
        
        [self.downloadRetryView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 5, self.mBubleImageView.frame.origin.y + 5, 70, 70)];
        
        if(alMessage.groupId)
        {
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            
            [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + 13,
                                                      self.mUserProfileImageView.frame.origin.y,
                                                      viewSize.width - 120, 110)];
            
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                                       self.mBubleImageView.frame.origin.y + 2,
                                                       self.mBubleImageView.frame.size.width + 30, 20);

            [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                                 self.mChannelMemberName.frame.origin.y + 5 +
                                                 self.mChannelMemberName.frame.size.height, 60, 60)];
            
            [self.downloadRetryView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 5, self.mImageView.frame.origin.y + 5, 70, 70)];
        }
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x, self.mBubleImageView.frame.size.height, 80, 20)];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + 15,
                                                      self.downloadRetryView.frame.origin.y + 5, 40, 40)];
        
        [self.sizeLabel setFrame:CGRectMake(self.downloadRetryView.frame.origin.x,
                                            self.mDowloadRetryButton.frame.origin.y + self.mDowloadRetryButton.frame.size.height,
                                            self.downloadRetryView.frame.size.width, 20)];
        
        [self.documentName setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width + 5,
                                               self.downloadRetryView.frame.origin.y,
                                               self.mBubleImageView.frame.size.width - self.mImageView.frame.size.width - 20, 60)];
        
        [self setupProgressValueX: (self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width/2 - 30)
                             andY: (self.downloadRetryView.frame.origin.y + self.downloadRetryView.frame.size.height/2 - 30)];
        
        [self.mImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentReceive.png"]];
        
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
        
        if (alMessage.imageFilePath == nil)
        {
            self.mDowloadRetryButton.alpha = 1;
            self.downloadRetryView.alpha = 1;
            self.sizeLabel.alpha = 1;
            [self.sizeLabel setText:[alMessage.fileMeta getTheSize]];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else
        {
             self.mDowloadRetryButton.alpha = 0;
            self.downloadRetryView.alpha = 0;
            self.sizeLabel.alpha = 0;
        }
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
            self.downloadRetryView.alpha = 0;
            self.sizeLabel.alpha = 0;
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
        
    }
    else
    {
        [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - 50, 0, 0, 45)];
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        [self.mMessageStatusImageView setHidden:NO];
        
        [self.documentName setTextColor:[UIColor whiteColor]];
        
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - 120, 80)];
        
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x, self.mBubleImageView.frame.origin.y + 10, 60, 60)];
        
        [self.downloadRetryView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 5, self.mBubleImageView.frame.origin.y + 5, 70, 70)];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + 15,
                                                      self.downloadRetryView.frame.origin.y + 5, 40, 40)];
        
        [self.sizeLabel setFrame:CGRectMake(self.downloadRetryView.frame.origin.x,
                                            self.mDowloadRetryButton.frame.origin.y + self.mDowloadRetryButton.frame.size.height,
                                            self.downloadRetryView.frame.size.width, 20)];
        
        [self.documentName setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width + 5,
                                               self.mBubleImageView.frame.origin.y + 5,
                                               self.mBubleImageView.frame.size.width - self.mImageView.frame.size.width - 20, 60)];

        [self setupProgressValueX: (self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width/2 - 30)
                             andY: (self.downloadRetryView.frame.origin.y + self.downloadRetryView.frame.size.height/2 - 30)];
        

        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - 20,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, 21);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y, 20, 20);
        
        [self.mImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentSend.png"]];
        
         msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.progresLabel.alpha = 0;
        
        self.mDowloadRetryButton.alpha = 0;
        self.downloadRetryView.alpha = 0;
        self.sizeLabel.alpha = 0;
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            //            NSLog(@"calling you progress label....");
        }
        else if(!alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
             self.mDowloadRetryButton.alpha = 1;
            self.downloadRetryView.alpha = 1;
            self.sizeLabel.alpha = 1;
            [self.sizeLabel setText:[alMessage.fileMeta getTheSize]];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
              self.mDowloadRetryButton.alpha = 1;
            self.downloadRetryView.alpha = 1;
            self.sizeLabel.alpha = 1;
            [self.sizeLabel setText:[alMessage.fileMeta getTheSize]];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
    }
    
    [self.documentName setText:alMessage.fileMeta.name];
    [self.mImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if(alMessage.imageFilePath != nil && alMessage.fileMeta.blobKey)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        [self.mBubleImageView setUserInteractionEnabled:YES];
        [self.mBubleImageView addGestureRecognizer:self.tapper];
        fileSourceURL = [NSURL fileURLWithPath:filePath];
        [self.mImageView setHidden:NO];
    }
    
    [self addShadowEffects];
    
    self.mDateLabel.text = theDate;
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT])
    {
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue)
        {
            case DELIVERED_AND_READ :
            {
                imageName = @"ic_action_read.png";
            }
                break;
            case DELIVERED:
            {
                imageName = @"ic_action_message_delivered.png";
            }
                break;
            case SENT:
            {
                imageName = @"ic_action_message_sent.png";
            }
                break;
            default:
            {
                imageName = @"ic_action_about.png";
            }
                break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    return self;
}

-(void) addShadowEffects
{
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
}

-(void) setupProgressValueX:(CGFloat)cooridinateX andY:(CGFloat)cooridinateY
{
    self.progresLabel = [[KAProgressLabel alloc] init];
    self.progresLabel.cancelButton.frame = CGRectMake(10, 10, 40, 40);
    [self.progresLabel.cancelButton setBackgroundImage:[ALUtilityClass getImageFromFramworkBundle:@"DELETEIOSX.png"] forState:UIControlStateNormal];
    [self.progresLabel setFrame:CGRectMake(cooridinateX, cooridinateY, 60, 60)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview: self.progresLabel];
}

-(void)downloadRetry
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

//========================================================================================
#pragma mark - UIDocumentInteraction Delegate Methods
//========================================================================================

-(void)suggestionAction
{
    if(!fileSourceURL)
    {
        return;
    }
    
    //    NSLog(@"CALL_GESTURE_SELECTOR FILE_URL : %@",fileSourceURL);
    [self.delegate showSuggestionView:fileSourceURL andFrame:[self.imageView frame]];
}
//========================================================================================
#pragma mark - KAProgressLabel Delegate Methods
//========================================================================================

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

- (void)dealloc
{
    if(super.mMessage.fileMeta)
    {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

-(void)setMMessage:(ALMessage *)mMessage
{
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
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (action == @selector(delete:) || action == @selector(msgInfo:));
    }
    
    return (action == @selector(delete:));
}

-(void) delete:(id)sender
{
    //UI
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
    
    [launchChat setMessage:self.mMessage andHeaderHeight:msgFrameHeight  withCompletionHandler:^(NSError *error) {
        
        if(!error)
        {
            [self.delegate loadViewForMedia:launchChat];
        }
    }];
}

@end
