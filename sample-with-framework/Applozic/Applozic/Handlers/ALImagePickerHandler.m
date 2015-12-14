//
//  ALImagePickerHandler.m
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALImagePickerHandler.h"

@implementation ALImagePickerHandler


+(NSString *) saveImageToDocDirectory:(UIImage *) image
{
    NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * timestamp = [NSString stringWithFormat:@"%f.local",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString * filePath = [docDirPath stringByAppendingPathComponent:timestamp];
    NSData * imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
}


@end
