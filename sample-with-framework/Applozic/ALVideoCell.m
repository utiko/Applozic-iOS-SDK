//
//  ALVideoCell.m
//  Applozic
//
//  Created by devashish on 23/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALVideoCell.h"
#import "UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"
#define DATE_LABEL_SIZE 12

@implementation ALVideoCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self)
    {
        [self.mDowloadRetryButton addTarget:self action:@selector(downloadRetryAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFullScreen:)];
        self.tapper.numberOfTapsRequired = 1;
        [self.contentView addSubview:self.mImageView];
        [self.mImageView setImage: [ALUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];
        
        self.videoPlayFrontView = [[UIImageView alloc] init];
        [self.videoPlayFrontView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
        [self.videoPlayFrontView setContentMode:UIViewContentModeScaleAspectFit];
        [self.videoPlayFrontView setImage: [ALUtilityClass getImageFromFramworkBundle:@"playImage.png"]];
        [self.contentView addSubview:self.videoPlayFrontView];
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

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    
    self.progresLabel.alpha = 0;
    [self.mNameLabel setHidden:YES];
    self.mMessage = alMessage;
    
     [self.mMessageStatusImageView setHidden:YES];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        [self.mUserProfileImageView setFrame:CGRectMake(5, 5, 45, 45)];
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + 13, self.mUserProfileImageView.frame.origin.y, viewSize.width - 120, viewSize.width - 160)];
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y + 5 , self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 10)];
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x, self.mBubleImageView.frame.size.height + 7, 80, 20)];
        
        ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:alMessage.to]];
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:alMessage.to];
        }
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 45 , self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 20 , 90, 40)];
        
        [self setupProgressValueX: (self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2 - 30) andY: (self.mBubleImageView.frame.origin.y +self.mBubleImageView.frame.size.height/2 - 30)];
        
        if (alMessage.imageFilePath == nil)
        {
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.mDowloadRetryButton setHidden:YES];
        }
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            [self.mDowloadRetryButton setHidden:YES];
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
        
    }
    else
    {
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - 45 - 5 , 5, 45, 45)];
        }
        else
        {
            [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - 45 - 5 , 5, 0, 45)];
        }

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        [self.mDowloadRetryButton setHidden:YES];
        
        [self.mMessageStatusImageView setHidden:NO];
        
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), 0, viewSize.width - 120, viewSize.width - 160)];
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y + 5 , self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 10)];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 45 , self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 20 , 90, 40)];
        
        
        [self setupProgressValueX: (self.mBubleImageView.frame.origin.x +self.mBubleImageView.frame.size.width/2 - 30) andY: (self.mBubleImageView.frame.origin.y +self.mBubleImageView.frame.size.height/2 - 30)];
        
        self.progresLabel.alpha = 0;
        
        
        self.status = @"";
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - 20, self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, 21);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            NSLog(@"calling you progress label....");
        }
        else if(!alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
        
    }
    
    [self.contentView bringSubviewToFront:self.videoPlayFrontView];
    [self.videoPlayFrontView setFrame:self.mImageView.frame];
    [self.videoPlayFrontView setHidden:YES];
    
    if(alMessage.imageFilePath != nil)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        self.videoFileURL = [NSURL fileURLWithPath:filePath];
        [self.mImageView addGestureRecognizer:self.tapper];
        [self.videoPlayFrontView setHidden:NO];
        [self setVideoThumbnail:filePath];
    }
    
    [self.mImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.mImageView setBackgroundColor:[UIColor whiteColor]];
    
    [self addShadowEffects];
    
    self.mDateLabel.text = theDate;
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]) { //@"5"
        
        if(alMessage.delivered == YES)
        {
            self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_message_delivered.png"];
        }
        else if(alMessage.sent == YES)
        {
            self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_message_sent.png"];
        }
        else
        {
            self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_about.png"];
        }
        
    }


    return self;
}

-(void)setVideoThumbnail:(NSString *)videoFilePATH
{
    NSURL *url = [NSURL fileURLWithPath:videoFilePATH];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [self.mImageView setImage:thumbnail];
}

-(void) downloadRetryAction
{
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
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

-(void)videoFullScreen:(UITapGestureRecognizer *)sender
{
    MPMoviePlayerViewController * videoViewController = [[MPMoviePlayerViewController alloc] initWithContentURL: self.videoFileURL];
    [videoViewController.moviePlayer setFullscreen:YES];
    [videoViewController.moviePlayer setScalingMode: MPMovieScalingModeAspectFit];
   
    [self.delegate showVideoFullScreen:videoViewController];
}

-(void) cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(delete:));
}

-(void) delete:(id)sender
{
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

@end
