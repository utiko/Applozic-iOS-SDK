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

static NSString * const reuseIdentifier = @"collectionCell";

- (void)viewDidLoad {
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
//     NSLog(@"VIEW_WILL_APPEAR_CALLED");
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 90,  self.view.frame.size.width, 90)];
    [bottomView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview: bottomView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(bottomView.frame.origin.x + 20, bottomView.frame.origin.y + 20, 120, 50)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"ADD MORE" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(gestureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *sendbutton = [[UIButton alloc] initWithFrame:CGRectMake(bottomView.frame.size.width - 140 , bottomView.frame.origin.y + 20, 120, 50)];
    [sendbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendbutton setTitle:@"SEND" forState:UIControlStateNormal];
    [sendbutton setBackgroundColor:[UIColor clearColor]];
    [sendbutton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendbutton];
    
}

//====================================================================================================================================
#pragma mark UIImagePicker Delegate
//====================================================================================================================================

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [ALApplozicSettings getColorForNavigationItem], NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:18]}];
    [navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
    [navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image getCompressedImageLessThanSize:5];
    UIImage * globalThumbnail = [UIImage new];
    NSString * attchmnetfilePath = @"";
    if(image)
    {
        NSString * filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
        globalThumbnail = image;
        attchmnetfilePath = filePath;
    }
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeMovie) != 0;
    if(isMovie)
    {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        NSString *videoFilePath = [ALImagePickerHandler saveVideoToDocDirectory:videoURL];
        globalThumbnail = [ALUtilityClass setVideoThumbnail:videoFilePath];
         attchmnetfilePath = videoFilePath;
    }

    [self.imageArray addObject:globalThumbnail];
    [self.imageFilePathArray addObject:attchmnetfilePath];
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
    cell.layer.borderColor = [[UIColor blueColor] CGColor];
    cell.layer.borderWidth = 3.0f;
    
    [cell.imageView setImage: (UIImage *)[self.imageArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)gestureAction
{
    if(self.imageArray.count >= 5)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"OOPS!!!"
                                                        message: @"MAXIMUM 5 ITEMS PLEASE!"
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
