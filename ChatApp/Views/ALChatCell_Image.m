//
//  ALChatCell_Image.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALChatCell_Image.h"


@implementation ALChatCell_Image

@synthesize mBubleImageView,mDateLabel,mImageView,mMessageStatusImageView,mUserProfileImageView,mDowloadRetryButton,progresLabel;

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
        
        
        progresLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(mImageView.frame.origin.x + mImageView.frame.size.width/2.0 , mImageView.frame.origin.y + mImageView.frame.size.height/2.0 , 50, 50)];
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
        
        mDowloadRetryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        mDowloadRetryButton.frame = CGRectMake(mImageView.frame.origin.x + mImageView.frame.size.width/2.0 - 50 , mImageView.frame.origin.y + mImageView.frame.size.height/2.0 - 20 , 100, 40);
        
        [mDowloadRetryButton addTarget:self action:@selector(dowloadRetryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [mDowloadRetryButton setTitle:@"Retry" forState:UIControlStateNormal];
        
        [mDowloadRetryButton setContentMode:UIViewContentModeCenter];
        
        [mDowloadRetryButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
        
        mDowloadRetryButton.layer.cornerRadius = 4;
        
        [mDowloadRetryButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        
        [self.contentView addSubview:mDowloadRetryButton];
        
    }
    
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
    [_delegate dowloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

- (void)dealloc
{
    if(_mMessage.fileMetas){
        [_mMessage.fileMetas removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

-(void)setMMessage:(ALMessage *)mMessage{
    if(_mMessage.fileMetas){
        [_mMessage.fileMetas removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
    _mMessage = mMessage;
    
    [_mMessage.fileMetas addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo=(ALFileMetaInfo *)object;
    
    self.progresLabel.endDegree = metaInfo.progressValue;
}

@end
