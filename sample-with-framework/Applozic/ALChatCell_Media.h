//
//  ALChatCell_Media.h
//  Applozic
//
//  Created by devashish on 20/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALMessage.h"
#import "ALColorUtility.h"
#import "ALApplozicSettings.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageService.h"
#import "ALContactDBService.h"
#import "KAProgressLabel.h"
#import "ALUtilityClass.h"

@protocol ALChatCellMediaDelegate <NSObject>

-(void) downloadRetryButtonActionDelegate:(int) index andMessage:(ALMessage *) message;
-(void) stopDownloadForIndex:(int)index andMessage:(ALMessage *)message;
-(void) deleteMessageFromView:(ALMessage *)message;

@end

@interface ALChatCell_Media : UITableViewCell

@property (nonatomic, retain) UIImageView * bubbleImageView;
@property (nonatomic, retain) UILabel * dateLabel;
@property (nonatomic, retain) UIImageView * userProfileImageView;
@property (nonatomic, retain) UIButton * playPauseStop;
@property (nonatomic, retain) UIProgressView *mediaTrackProgress;
@property (nonatomic, retain) UILabel *mediaTrackLength;
@property (nonatomic, retain) UIButton * dowloadRetryButton;
@property (nonatomic, retain) KAProgressLabel *progresLabel;
@property (nonatomic, retain) UILabel *mediaName;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@property (nonatomic, assign) id<ALChatCellMediaDelegate> delegate;

@property (nonatomic, retain) ALMessage * alMessage;

-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;

-(void) getProgressOfTrack;
-(void) mediaButtonAction;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(void) setupProgressValueX:(CGFloat)cooridinateX andY:(CGFloat)cooridinateY;
-(void) dowloadRetryAction;
-(void) cancelAction;

@property (nonatomic) int count;

@end
