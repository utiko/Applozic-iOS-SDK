//
//  ALVideoCell.h
//  Applozic
//
//  Created by devashish on 24/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Applozic/Applozic.h>

@interface ALVideoCell : ALMediaBaseCell

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;
-(void) dismissModelView:(UITapGestureRecognizer *)gesture;
-(void) videoFullScreen:(UITapGestureRecognizer *)sender;
-(void) downloadRetryAction;
-(void)setVideoThumbnail:(NSString *)videoFilePATH;

@property (nonatomic, strong) UITapGestureRecognizer *tapper;
@property (nonatomic, strong) NSURL *videoFileURL;

@property (nonatomic, strong) UIImageView * videoPlayFrontView;

@end
