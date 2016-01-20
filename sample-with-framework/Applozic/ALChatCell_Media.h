//
//  ALChatCell_Media.h
//  Applozic
//
//  Created by devashish on 20/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALMessage.h"
#import "ALColorUtility.h"
#import "ALApplozicSettings.h"
#import "ALUserDefaultsHandler.h"
#import "KAProgressLabel.h"

@interface ALChatCell_Media : UITableViewCell

@property (nonatomic, strong) UIImageView * bubbleImageView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UIImageView * userProfileImageView;
@property (nonatomic, strong) UIButton * playPauseStop;
@property (nonatomic, strong) UIProgressView *mediaTrackProgress;
@property (nonatomic, strong) UILabel *mediaTrackLength;

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;

@end
