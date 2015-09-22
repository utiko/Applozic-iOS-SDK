//
//  ALChatCell.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALChatCell.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"

@implementation ALChatCell

@synthesize mMessageLabel,mBubleImageView,mDateLabel,mUserProfileImageView,mMessageStatusImageView;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:1];
        
        mBubleImageView = [[UIImageView alloc] init];
        
        mBubleImageView.frame = CGRectMake(5, 5, 100, 44);
        
        mBubleImageView.contentMode = UIViewContentModeScaleToFill;
        
        mBubleImageView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:mBubleImageView];
        
        
        mUserProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        
        mUserProfileImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        mUserProfileImageView.clipsToBounds = YES;
        
        [self.contentView addSubview:mUserProfileImageView];
        
        
        mMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 100, 44)];
        
        NSString *fontName = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_FONTNAME];
        
        if (!fontName) {
            fontName = DEFAULT_FONT_NAME;
        }
        
        mMessageLabel.font = [UIFont fontWithName:fontName size:15];
        
        mMessageLabel.numberOfLines = 0;
        
        mMessageLabel.textColor = [UIColor grayColor];
        
        [self.contentView addSubview:mMessageLabel];
        

        mDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 25)];
        
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
        
    }
    
    return self;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}


@end
