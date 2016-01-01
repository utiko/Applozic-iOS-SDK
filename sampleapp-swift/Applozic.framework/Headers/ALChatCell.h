//
//  ALChatCell.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMessage.h"

@protocol ALChatCellDelegate <NSObject>

-(void) deleteMessageFromView:(ALMessage *) message;

@end

@interface ALChatCell : UITableViewCell

@property (retain, nonatomic) UITextView *mMessageLabel;

@property (retain, nonatomic) UILabel *mDateLabel;

@property (nonatomic,retain) UIImageView * mBubleImageView;

@property (nonatomic,retain) UIImageView * mUserProfileImageView;

@property (nonatomic, retain) ALMessage * mMessage;

@property (nonatomic, retain) UIImageView *mMessageStatusImageView;

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;

@property (nonatomic, assign) id<ALChatCellDelegate> delegate;

@property (strong, nonatomic) NSString *status;

@property (strong, nonatomic) NSString *string;

@end
