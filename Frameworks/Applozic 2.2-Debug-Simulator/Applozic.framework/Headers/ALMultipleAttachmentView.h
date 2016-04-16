//
//  ALMultipleAttachmentView.h
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALMUltipleAttachmentDelegate <NSObject,UITextFieldDelegate>
@required

-(void) multipleAttachmentProcess:(NSMutableArray *)attachmentPathArray;

@end

@interface ALMultipleAttachmentView : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray * imageArray;
@property (nonatomic, strong) NSMutableArray * imageFilePathArray;
@property (nonatomic, weak) id <ALMUltipleAttachmentDelegate> multipleAttachmentDelegate;

@end
