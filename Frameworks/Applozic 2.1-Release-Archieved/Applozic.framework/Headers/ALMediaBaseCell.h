//
//  ALMediaBaseCell.h
//  Applozic
//
//  Created by devashish on 19/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#define DATE_LABEL_SIZE 12
#define MESSAGE_TEXT_SIZE 14

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
#import "ALMessage.h"
#import "ALApplozicSettings.h"
#import "ALConstant.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol ALMediaBaseCellDelegate <NSObject>

-(void) downloadRetryButtonActionDelegate:(int) index andMessage:(ALMessage *) message;
-(void) stopDownloadForIndex:(int)index andMessage:(ALMessage *)message;
-(void) showFullScreen:(UIViewController *) fullView;
-(void) deleteMessageFromView:(ALMessage *)message;
-(void) loadView:(UIViewController *)launch;
-(void) showVideoFullScreen:(MPMoviePlayerViewController *)fullView;
-(void) showSuggestionView:(NSURL *)fileURL andFrame:(CGRect)frame;

@end

@interface ALMediaBaseCell : UITableViewCell <KAProgressLabelDelegate>

@property (retain, nonatomic) UIImageView * mImageView;
@property (retain, nonatomic) UILabel *mDateLabel;
@property (nonatomic, retain) UIImageView * mBubleImageView;
@property (nonatomic, retain) UIImageView * mUserProfileImageView;
@property (retain, nonatomic) UILabel *mNameLabel;
@property (nonatomic, retain) ALMessage * mMessage;
@property (nonatomic, retain) UIImageView *mMessageStatusImageView;
@property (nonatomic, retain) UIButton * mDowloadRetryButton;
@property (nonatomic, retain) KAProgressLabel *progresLabel;
@property (nonatomic, strong) UITextView *imageWithText;
@property (retain, nonatomic) UILabel *mChannelMemberName;

@property (nonatomic, assign) id <ALMediaBaseCellDelegate> delegate;     

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;
-(void)setupProgress;
-(void)dowloadRetryButtonAction;
-(void)hidePlayButtonOnUploading;

@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIView *downloadRetryView;

@end
