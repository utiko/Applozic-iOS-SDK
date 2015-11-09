//
//  ALChatCell_Image.h
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALMessage.h"

#import "KAProgressLabel.h"

@protocol ALChatCellImageDelegate <NSObject>

-(void) downloadRetryButtonActionDelegate:(int) index andMessage:(ALMessage *) message;
-(void) stopDownloadForIndex:(int)index andMessage:(ALMessage *)message;
-(void) showFullScreen:(UIViewController *) fullView;
-(void)deleteMessageFromView:(ALMessage *)message;

@end


@interface ALChatCell_Image : UITableViewCell<KAProgressLabelDelegate>

@property (retain, nonatomic) UIImageView * mImageView;

@property (retain, nonatomic) UILabel *mDateLabel;

@property (nonatomic,retain) UIImageView * mBubleImageView;

@property (nonatomic,retain) UIImageView * mUserProfileImageView;

@property (nonatomic, retain) ALMessage * mMessage;

@property (nonatomic, retain) UIImageView *mMessageStatusImageView;

@property (nonatomic,retain) UIButton * mDowloadRetryButton;

@property (nonatomic, retain) KAProgressLabel *progresLabel;

@property (nonatomic, assign) id<ALChatCellImageDelegate> delegate;

@property (nonatomic, strong) UITextView *imageWithText;

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;




@end
