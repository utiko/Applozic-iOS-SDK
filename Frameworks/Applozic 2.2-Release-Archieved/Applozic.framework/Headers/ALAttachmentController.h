//
//  ALImageWithTextController.h
//  ChatApp
//
//  Created by devashish on 31/10/2015.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALApplozicSettings.h"

@protocol ALImageWithTextControllerDelegate <NSObject,UITextFieldDelegate>
@required
-(void) check:(UIImage *)imageFile andText:(NSString *)textwithimage;

@end

@interface ALAttachmentController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textMessageWithImage;

@property (weak, nonatomic) IBOutlet UIImageView *pickedImageView;

@property (nonatomic, strong) UIImage *imagedocument;

- (IBAction)cancelButtonAction:(id)sender;

- (IBAction)sendButtonAction:(id)sender;

- (void) setImageViewMethod:(UIImage *)image;

@property (nonatomic, weak) id<ALImageWithTextControllerDelegate>imagecontrollerDelegate;

@end
