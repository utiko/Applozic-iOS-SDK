//
//  ALMultipleAttachmentView.m
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMultipleAttachmentView.h"
#import "AlMultipleAttachmentCell.h"
#import "ALUtilityClass.h"
#import "ALChatViewController.h"
#import "ALImagePickerHandler.h"

@interface ALMultipleAttachmentView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapper;
@property (nonatomic, retain) UIImagePickerController * mImagePicker;

@end

@implementation ALMultipleAttachmentView
{
    CGFloat SQUARE_DIMENSION;
    CGFloat SEND_BUTTON_X;
    CGFloat ADD_BUTTON_X;
    CGFloat ADJUST_Y;
    CGFloat ADJUST_VIEW_CONSTANT;
}

static NSString * const reuseIdentifier = @"collectionCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.mImagePicker = [UIImagePickerController new];
    self.mImagePicker.delegate = self;
    
    self.imageArray = [NSMutableArray new];
    self.imageFilePathArray = [NSMutableArray new];
    //    NSLog(@"VIEW_DID_LOAD CALLED");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    SQUARE_DIMENSION = 60;
    ADJUST_Y = 10;
    ADJUST_VIEW_CONSTANT = 90;
    
    UIColor *buttonColor = [UIColor colorWithRed:231.0/255 green:90.0/255 blue:77.0/255 alpha:1.0];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - ADJUST_VIEW_CONSTANT,
                                                                  self.view.frame.size.width,
                                                                  ADJUST_VIEW_CONSTANT)];
    
    [bottomView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview: bottomView];
    
    ADD_BUTTON_X = bottomView.frame.origin.x + 20;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ADD_BUTTON_X,
                                                                  bottomView.frame.origin.y + ADJUST_Y,
                                                                  SQUARE_DIMENSION, SQUARE_DIMENSION)];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setContentMode:UIViewContentModeScaleAspectFit];
    [button setImage:[ALUtilityClass getImageFromFramworkBundle:@"Plus_PNG.png"] forState:UIControlStateNormal];
    [button setBackgroundColor: buttonColor];
    [button addTarget:self action:@selector(gestureAction) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = button.frame.size.width/2;
    button.layer.masksToBounds = YES;
    [self.view addSubview:button];
    
    SEND_BUTTON_X = bottomView.frame.size.width - 80;
    
    UIButton *sendbutton = [[UIButton alloc] initWithFrame:CGRectMake(SEND_BUTTON_X,
                                                                      bottomView.frame.origin.y + ADJUST_Y,
                                                                      SQUARE_DIMENSION, SQUARE_DIMENSION)];
    
    [sendbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendbutton setContentMode:UIViewContentModeScaleAspectFit];
    [sendbutton setImage:[ALUtilityClass getImageFromFramworkBundle:@"send_PNG2.png"] forState:UIControlStateNormal];
    [sendbutton setBackgroundColor: buttonColor];
    [sendbutton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    sendbutton.layer.cornerRadius = sendbutton.frame.size.width/2;
    sendbutton.layer.masksToBounds = YES;
    [self.view addSubview:sendbutton];
    
}

//====================================================================================================================================
#pragma mark UIImagePicker Delegate
//====================================================================================================================================

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:
                                                                [ALApplozicSettings getColorForNavigationItem],
                                                                NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:18]}];
    
    [navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
    [navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image getCompressedImageLessThanSize:1];
    UIImage * globalThumbnail = [UIImage new];
    NSString * attachmentFilePath = @"";
    if(image)
    {
        NSString * filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
        globalThumbnail = image;
        attachmentFilePath = filePath;
    }
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeMovie) != 0;
    if(isMovie)
    {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        NSString *videoFilePath = [ALImagePickerHandler saveVideoToDocDirectory:videoURL];
        globalThumbnail = [ALUtilityClass setVideoThumbnail:videoFilePath];
        attachmentFilePath = videoFilePath;
    }
    
    [self.imageArray addObject:globalThumbnail];
    [self.imageFilePathArray addObject:attachmentFilePath];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //    NSLog(@"ADD_ACTION_CALLED ARRAY_COUNT %lu", (unsigned long)self.imageArray.count);
    [self.collectionView reloadData];
}

//====================================================================================================================================
#pragma mark UICollectionView DataSource
//====================================================================================================================================

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlMultipleAttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.layer.masksToBounds = YES;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.layer.borderWidth = 2.0f;
    
    [cell.imageView setImage: (UIImage *)[self.imageArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)gestureAction
{
    int MAX_VALUE = (int)[ALApplozicSettings getMultipleAttachmentMaxLimit];
    if(self.imageArray.count >= MAX_VALUE)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"OOPS!!!"
                                                        message: [NSString stringWithFormat:@"MAXIMUM %d ITEMS PLEASE", MAX_VALUE]
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"MEDIA TYPE" message:@"CHOOSE ATTACHMENT TYPE"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* image = [UIAlertAction actionWithTitle:@"IMAGE" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [self pickImageFromGallery];
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction* video = [UIAlertAction actionWithTitle:@"VIDEO" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [self pickVideoFromGallery];
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:image];
    [alert addAction:video];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)sendButtonAction
{
    NSLog(@"SEND_ACTION_CALLED");   // either call by object ot call by delgate to send array
    [self.multipleAttachmentDelegate multipleAttachmentProcess:self.imageFilePathArray];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pickImageFromGallery
{
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
}

-(void)pickVideoFromGallery
{
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
}

//====================================================================================================================================
#pragma mark UICollectionView Delegate
//====================================================================================================================================

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
