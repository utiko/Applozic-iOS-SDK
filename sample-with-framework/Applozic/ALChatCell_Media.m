//
//  ALChatCell_Media.m
//  Applozic
//
//  Created by devashish on 20/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALChatCell_Media.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"

@implementation ALChatCell_Media


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.bubbleImageView = [[UIImageView alloc] init];
        [self.bubbleImageView setBackgroundColor:[UIColor whiteColor]];
        self.bubbleImageView.layer.cornerRadius = 10;
        self.bubbleImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.bubbleImageView];
        
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextColor:[UIColor blackColor]];
        [self.dateLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.dateLabel];
        
        self.userProfileImageView = [[UIImageView alloc] init];
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width/2;
        self.userProfileImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.userProfileImageView];
        
        self.playPauseStop = [[UIButton alloc] init];
        [self.playPauseStop addTarget:self action:@selector(mediaButtonAction) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:self.playPauseStop];
        
        self.mediaTrackProgress = [[UIProgressView alloc] init];
        [self.contentView addSubview:self.mediaTrackProgress];
        
        self.mediaTrackLength = [[UILabel alloc] init];
        [self.contentView addSubview:self.mediaTrackLength];
        
        /*
         
         self.mBubleImageView.layer.shadowOpacity = 0.3;
         self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
         self.mBubleImageView.layer.shadowRadius = 1;
         self.mBubleImageView.layer.masksToBounds = NO;
         
         */
        // need progrss label
    }
    
    return self;
    
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        [self.userProfileImageView setFrame:CGRectMake(5, 0, 45, 45)];
        [self.bubbleImageView setFrame:CGRectMake(self.userProfileImageView.frame.origin.x + self.userProfileImageView.frame.size.width + 13, self.userProfileImageView.frame.origin.y, 100, 70)];
        [self.dateLabel setFrame:CGRectMake(self.bubbleImageView.frame.origin.x, self.bubbleImageView.frame.origin.x +  self.bubbleImageView.frame.size.width + 5, self.bubbleImageView.frame.size.width/2, 20)];
        
        // rest logic
        
        
    }
    else
    {
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.userProfileImageView setFrame:CGRectMake(viewSize.width - 45 - 5 , 0, 45, 45)];
        }
        else
        {
            [self.userProfileImageView setFrame:CGRectMake(viewSize.width - 45 - 5 , 0, 0, 45)];
        }
        
        [self.bubbleImageView setFrame:CGRectMake(viewSize.width - 100 - 13, self.userProfileImageView.frame.origin.y, 100, 70)];
        
        
    }
    
    return self;
}

-(void)mediaButtonAction
{
    //play pause and stop action
}

-(NSString *)getProgressOfTrack
{
    
    return @"";
}

@end
