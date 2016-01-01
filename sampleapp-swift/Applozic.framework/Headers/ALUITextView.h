//
//  ALUITextView.h
//  ChatApp
//
//  Created by devashish on 19/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ALUITextView : UITextView<UITextViewDelegate>


-(BOOL)canBecomeFirstResponder;

@end