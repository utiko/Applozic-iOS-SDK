//
//  ALChatCell.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMessage.h"

@interface ALChatCell : UITableViewCell

//@property (retain, nonatomic) UILabel *mMessageLabel;

@property (retain, nonatomic) UITextView *mMessageLabel;

@property (retain, nonatomic) UILabel *mDateLabel;

@property (nonatomic,retain) UIImageView * mBubleImageView;

@property (nonatomic,retain) UIImageView * mUserProfileImageView;

@property (nonatomic, retain) ALMessage * mMessage;

@property (nonatomic, retain) UIImageView *mMessageStatusImageView;

-(void)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;

@end
