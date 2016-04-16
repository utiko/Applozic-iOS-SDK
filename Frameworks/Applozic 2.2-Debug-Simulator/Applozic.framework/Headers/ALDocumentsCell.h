//
//  ALDocumentsCell.h
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
//  THIS CELL IS BASICALLY FOR DOCUMENTS LIKE PPTX, PDF, DOCX etc.

#import <UIKit/UIKit.h>
#import "ALMediaBaseCell.h"

@interface ALDocumentsCell : ALMediaBaseCell

@property (nonatomic, strong) UILabel * documentName;
@property (nonatomic, strong) UITapGestureRecognizer *tapper;

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;

@end
