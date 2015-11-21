//
//  ALChatCell_Image.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALChatCell_Image.h"
#import "UIImageView+WebCache.h"
#import "ALDBHandler.h"
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"



@implementation ALChatCell_Image

@synthesize mBubleImageView,mDateLabel,mImageView,mMessageStatusImageView,mUserProfileImageView,mDowloadRetryButton,progresLabel,imageWithText;

UIViewController * modalCon;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:1];
        
        
        mUserProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        
        mUserProfileImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        mUserProfileImageView.clipsToBounds = YES;
        
        [self.contentView addSubview:mUserProfileImageView];
        
        
        
        mBubleImageView = [[UIImageView alloc] init];
        
        mBubleImageView.frame = CGRectMake(mUserProfileImageView.frame.origin.x+mUserProfileImageView.frame.size.width+5 , 5, self.frame.size.width-110, self.frame.size.width-110);
        
        mBubleImageView.contentMode = UIViewContentModeScaleToFill;
        
        mBubleImageView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:mBubleImageView];
        
        
        
        mImageView = [[UIImageView alloc] init];
        
        mImageView.frame = CGRectMake(mBubleImageView.frame.origin.x + 5 , mBubleImageView.frame.origin.y + 15 , mBubleImageView.frame.size.width - 10 , mBubleImageView.frame.size.height - 40 );
        
        mImageView.contentMode = UIViewContentModeScaleAspectFill;
        mImageView.clipsToBounds = YES;
        mImageView.backgroundColor = [UIColor grayColor];
        mImageView.clipsToBounds = YES;
        mImageView.userInteractionEnabled = YES;
        
        
        
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageFullScreen:)];
        tapper.numberOfTapsRequired = 1;
        [mImageView addGestureRecognizer:tapper];
        
        [self.contentView addSubview:mImageView];
        
        
        
        mDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(mBubleImageView.frame.origin.x + 5, mImageView.frame.origin.y + mImageView.frame.size.height + 5, 100, 20)];
        
        mDateLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
        
        mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        mDateLabel.numberOfLines = 1;
        
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0  alpha:1];
        
        [self.contentView addSubview:mDateLabel];
        
        
        mMessageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(mDateLabel.frame.origin.x+mDateLabel.frame.size.width, mDateLabel.frame.origin.y, 20, 20)];
        
        mMessageStatusImageView.contentMode = UIViewContentModeScaleToFill;
        
        mMessageStatusImageView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:mMessageStatusImageView];
        
        
        
        
        
        mDowloadRetryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        mDowloadRetryButton.frame = CGRectMake(mImageView.frame.origin.x + mImageView.frame.size.width/2.0 - 50 , mImageView.frame.origin.y + mImageView.frame.size.height/2.0 - 20 , 100, 40);
        
        [mDowloadRetryButton addTarget:self action:@selector(dowloadRetryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [mDowloadRetryButton setTitle:@"Retry" forState:UIControlStateNormal];
        
        [mDowloadRetryButton setContentMode:UIViewContentModeCenter];
        
        [mDowloadRetryButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
        
        mDowloadRetryButton.layer.cornerRadius = 4;
        
        [mDowloadRetryButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        
        [self.contentView addSubview:mDowloadRetryButton];
        
        imageWithText = [[UITextView alloc] init];
        imageWithText.clipsToBounds = YES;
        imageWithText.contentMode = UIViewContentModeScaleAspectFill;
        [imageWithText setFont:[UIFont systemFontOfSize:15]];
        imageWithText.editable = NO;
        imageWithText.scrollEnabled = NO;
        imageWithText.dataDetectorTypes = UIDataDetectorTypeAll;
        
        
        [self.contentView addSubview:imageWithText];
        
    }
    
    return self;
    
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize {
    self.mUserProfileImageView.alpha=1;
    self.progresLabel.alpha = 0;
    self.mDowloadRetryButton.alpha = 0;
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTime:today]];
    self.mMessage = alMessage;
    CGSize theDateSize = [self getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    CGSize theTextSize = [self getSizeForText:alMessage.message maxWidth:viewSize.width-115 font:self.imageWithText.font.fontName fontSize:self.imageWithText.font.pointSize];
    
    if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT]) { //@"4" //Recieved Message
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 45, 45);
        }
        if([ALApplozicSettings getReceiveMsgColour])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColour];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        
        self.mUserProfileImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
        
        
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13 , 0, viewSize.width-110, viewSize.width-110);
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y + 15 , self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 40 );
        [self setupProgress];
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mImageView.frame.origin.y + self.mImageView.frame.size.height + 5, theDateSize.width , 20);
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        if(alMessage.message.length > 0)
        {
            
            imageWithText.frame = CGRectMake(mBubleImageView.frame.origin.x, mBubleImageView.frame.origin.y + mBubleImageView.frame.size.height, mBubleImageView.frame.size.width, theTextSize.height + 30);
            
            imageWithText.alpha = 1;
            
            mDateLabel.frame = CGRectMake(self.imageWithText.frame.origin.x + 5 , self.imageWithText.frame.origin.y + self.imageWithText.frame.size.height - 20, theDateSize.width , 20);
            
            [self.contentView bringSubviewToFront:mDateLabel];
            [self.contentView bringSubviewToFront:mMessageStatusImageView];
        }
        
        else
        {
            imageWithText.alpha = 0;
        }
        
        
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x+self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        if (alMessage.imageFilePath == NULL) {
            
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[UIImage imageNamed:@"ic_download.png"]
                                      forState:UIControlStateNormal];

        }else{
            
            self.mDowloadRetryButton.alpha = 0;
            
        }if (alMessage.inProgress == YES) {
            
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
            
        }else {
            
            self.progresLabel.alpha = 0;
            
        }
        
        ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
        
        if (alContact.localImageResourceName)
        {
            
            self.mUserProfileImageView.image = [UIImage imageNamed:alContact.localImageResourceName];
            
        }
        else if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            self.mUserProfileImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
        }
        
        
    }else{ //Sent Message
        
        
        if([ALApplozicSettings getSendMsgColour])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColour];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        
        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - 50, 5, 45, 45);
        
        self.mBubleImageView.frame = CGRectMake(viewSize.width - self.mUserProfileImageView.frame.origin.x + 50 , 5 ,viewSize.width-110, viewSize.width-110);
        
        self.mUserProfileImageView.alpha=0;
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y+15 ,self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 40);
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5, self.mImageView.frame.origin.y + self.mImageView.frame.size.height + 5 , theDateSize.width, 20);
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        if(alMessage.message.length > 0)
        {
            imageWithText.alpha = 1;
            imageWithText.frame = CGRectMake(mBubleImageView.frame.origin.x, mBubleImageView.frame.origin.y + mBubleImageView.frame.size.height, mBubleImageView.frame.size.width, theTextSize.height + 30);
            
            mDateLabel.frame = CGRectMake(self.imageWithText.frame.origin.x + 5 , self.imageWithText.frame.origin.y + self.imageWithText.frame.size.height - 20, theDateSize.width , 20);
            
            [self.contentView bringSubviewToFront:mDateLabel];
            [self.contentView bringSubviewToFront:mMessageStatusImageView];
            
        }
        else
        {
            imageWithText.alpha = 0;
            
        }
        
        
        
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x+self.mDateLabel.frame.size.width+10, self.mDateLabel.frame.origin.y, 20, 20);
        [self setupProgress];
        
        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;
        if (alMessage.inProgress == YES) {
            self.progresLabel.alpha = 1;
            NSLog(@"calling you progress label....");
        }else if( !alMessage.imageFilePath && alMessage.fileMeta.blobKey){
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[UIImage imageNamed:@"ic_download.png"]
                                      forState:UIControlStateNormal];
        }else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey){
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
        }
        
    }
    self.mDowloadRetryButton.frame = CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 50 , self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 15 , 100, 30);
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]) { //@"5"
        
        if(alMessage.delivered==YES){
            self.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_delivered.png"];
        }
        else if(alMessage.sent==YES){
            self.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_message_sent.png"];
        }else{
            self.mMessageStatusImageView.image = [UIImage imageNamed:@"ic_action_about.png"];
            
        }
        
    }
    imageWithText.text = alMessage.message;
    self.mDateLabel.text = theDate;
    
    NSURL * theUrl = nil ;
    if([alMessage.message hasPrefix:@"http://maps.googleapis.com/maps/api/staticmap"])
    {
        NSURL *ur=[NSURL URLWithString:alMessage.message];
        NSData* data = [NSData dataWithContentsOfURL:ur];
        UIImage *img = [UIImage imageWithData:data];
        [self.mImageView setImage:img];
        return self;
    }
    if (alMessage.imageFilePath!=NULL) {
        
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        theUrl = [NSURL fileURLWithPath:filePath];
    }
    else{
        theUrl = [NSURL URLWithString:alMessage.fileMeta.thumbnailUrl];
    }
    
    [self.mImageView sd_setImageWithURL:theUrl];
    return self;
    
}



#pragma mark - KAProgressLabel Delegate Methods -

-(void)cancelAction {
    
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)]) {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void) dowloadRetryButtonAction
{
    [_delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

- (void)dealloc
{
    if(_mMessage.fileMeta){
        [_mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

-(void)setMMessage:(ALMessage *)mMessage{
    //TODO: error ...observer shoud be there...
    if(_mMessage.fileMeta){
        [_mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
    _mMessage = mMessage;
    [_mMessage.fileMeta addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo=(ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree =0;
    self.progresLabel.endDegree = metaInfo.progressValue;
    NSLog(@"##observer is called....%f",self.progresLabel.endDegree );
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

-(void)imageFullScreen:(UITapGestureRecognizer*)sender {
    
    //if ( self.mMessage.imageFilePath ){
    
    modalCon = [[UIViewController alloc] init];
    modalCon.view.backgroundColor=[UIColor blackColor];
    modalCon.view.userInteractionEnabled=YES;
    UIImageView *imageViewNew = [[UIImageView alloc] initWithFrame:modalCon.view.frame];
    imageViewNew.contentMode=UIViewContentModeScaleAspectFit;
    imageViewNew.image=mImageView.image;
    [modalCon.view addSubview:imageViewNew];
    UITapGestureRecognizer *modalTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalView:)];
    [modalCon.view addGestureRecognizer:modalTap];
    [self.delegate showFullScreen:modalCon];
    //}else{
    //  NSLog(@" image is not present on  SDCARD...");
    //}
    return;
}

-(void)setupProgress{
    progresLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0-25, mImageView.frame.origin.y + mImageView.frame.size.height/2.0-25, 50, 50)];
    progresLabel.delegate = self;
    [progresLabel setTrackWidth: 5.0];
    [progresLabel setProgressWidth: 5];
    [progresLabel setStartDegree:0];
    [progresLabel setEndDegree:0];
    [progresLabel setRoundedCornersWidth:1];
    progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    progresLabel.trackColor = [UIColor redColor];
    progresLabel.progressColor = [UIColor greenColor];
    [self.contentView addSubview:progresLabel];
    
}

-(void)dismissModalView:(UITapGestureRecognizer*)gesture{
    
    [modalCon dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(delete:));
}

-(void) delete:(id)sender {
    [ self.delegate deleteMessageFromView:self.mMessage];
}


@end
