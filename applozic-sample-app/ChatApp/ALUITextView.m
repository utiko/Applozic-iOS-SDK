//
//  ALUITextView.m
//  ChatApp
//
//  Created by devashish on 19/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "ALUITextView.h"

@implementation ALUITextView 


-(BOOL)canBecomeFirstResponder{
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [[UIApplication sharedApplication] openURL:URL];
    NSLog(@"callled");
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}



@end