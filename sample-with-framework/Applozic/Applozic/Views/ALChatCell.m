//
//  ALChatCell.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#define MESSAGE_TEXT_SIZE 14
#define DATE_LABEL_SIZE 12

#import "ALChatCell.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"
#import "ALUITextView.h"
#import "UIImageView+WebCache.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"
#import "ALMessageService.h"
#import "ALMessageDBService.h"
#import "UIImage+Utility.h"
#import "ALColorUtility.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"


@implementation ALChatCell
{
    CGFloat msgFrameHeight;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:1];
        
        self.mUserProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        self.mUserProfileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mUserProfileImageView.layer.cornerRadius=self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.mUserProfileImageView];
        
        self.mBubleImageView = [[UIImageView alloc] init];
        self.mBubleImageView.contentMode = UIViewContentModeScaleToFill;
        self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        self.mBubleImageView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.mBubleImageView];
        
        self.mNameLabel = [[UILabel alloc] init];
        [self.mNameLabel setTextColor:[UIColor whiteColor]];
        [self.mNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.mNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        self.mNameLabel.textAlignment = NSTextAlignmentCenter;
        self.mNameLabel.layer.cornerRadius = self.mNameLabel.frame.size.width/2;
        self.mNameLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:self.mNameLabel];

        self.mMessageLabel = [[ALUITextView alloc] init];
        self.mMessageLabel.delegate = self.mMessageLabel;
        NSString *fontName = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_FONTNAME];
        
        if (!fontName) {
            fontName = DEFAULT_FONT_NAME;
        }
        self.mMessageLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_TEXT_SIZE];
        self.mMessageLabel.textColor = [UIColor grayColor];
        self.mMessageLabel.selectable = YES;
        self.mMessageLabel.editable = NO;
        self.mMessageLabel.scrollEnabled = NO;
        self.mMessageLabel.textContainerInset = UIEdgeInsetsZero;
        self.mMessageLabel.textContainer.lineFragmentPadding = 0;
        self.mMessageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
        self.mMessageLabel.userInteractionEnabled=NO;
        [self.contentView addSubview:self.mMessageLabel];
        
        self.mChannelMemberName = [[UILabel alloc] init];
        self.mChannelMemberName.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        self.mChannelMemberName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mChannelMemberName];
        
        self.mDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 25)];
        self.mDateLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE];
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        self.mDateLabel.numberOfLines = 1;
        [self.contentView addSubview:self.mDateLabel];
        
        self.mMessageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mDateLabel.frame.origin.x+
                                                                                     self.mDateLabel.frame.size.width,
                                                                                     self.mDateLabel.frame.origin.y, 20, 20)];
        self.mMessageStatusImageView.contentMode = UIViewContentModeScaleToFill;
        self.mMessageStatusImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mMessageStatusImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0  alpha:1];
        
        self.contentView.userInteractionEnabled = YES;
        
    }
    
    
    return self;
    
}


-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    
    self.mUserProfileImageView.alpha = 1;
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    self.mMessage = alMessage;
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    
    NSString *receiverName = alContact.displayName? alContact.displayName: alMessage.to;
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width-115 font:self.mMessageLabel.font.fontName fontSize:self.mMessageLabel.font.pointSize];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    CGSize receiverNameSize = [ALUtilityClass getSizeForText:receiverName maxWidth:viewSize.width-115 font:self.mChannelMemberName.font.fontName fontSize:self.mChannelMemberName.font.pointSize];
    
    [self.mBubleImageView setHidden:NO];
    [self.mDateLabel setHidden:NO];
    [self.mMessageLabel setTextAlignment:NSTextAlignmentLeft];
    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    self.mMessageStatusImageView.hidden = YES;
    [self.contentView bringSubviewToFront:self.mMessageStatusImageView];
    self.mUserProfileImageView.backgroundColor = [UIColor whiteColor];
 
    if([alMessage.type isEqualToString:@"100"])
    {
        [self dateTextSetupForALMessage:alMessage withViewSize:viewSize andTheTextSize:theTextSize];
    }
    else if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        [self.contentView bringSubviewToFront:self.mChannelMemberName];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 45, 45);
        }
        
        if([ALApplozicSettings getReceiveMsgColor])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
            self.mMessageLabel.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13,
                                                0,
                                                theTextSize.width + 18,
                                                theTextSize.height + 20);
        
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;

        
        self.mMessageLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 10 , 10, theTextSize.width, theTextSize.height);

        if([alMessage getGroupId])
        {
            [self.mChannelMemberName setHidden:NO];
          
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            
            if(theTextSize.width < receiverNameSize.width)
            {
                theTextSize.width = receiverNameSize.width;
            }
            
            self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13, 0, theTextSize.width + 20, theTextSize.height + 20 + 15);
            
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 10, self.mBubleImageView.frame.origin.y + 2, self.mBubleImageView.frame.size.width + 30, 20);
            
            self.mMessageLabel.frame = CGRectMake(self.mChannelMemberName.frame.origin.x, self.mChannelMemberName.frame.origin.y + self.mChannelMemberName.frame.size.height + 5, theTextSize.width, theTextSize.height);
            
            [self.mChannelMemberName setText:receiverName];
        }
        
        self.mMessageLabel.textColor = [UIColor grayColor];
        self.mMessageLabel.linkTextAttributes = @{
                                                  NSForegroundColorAttributeName : [UIColor grayColor],
                                                  NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleThick]
                                                  };
        
        if(alMessage.contentType == 3)
        {
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[alMessage.message dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            self.mMessageLabel.attributedText = attributedString;
        }
        else
        {
            self.mMessageLabel.text = alMessage.message;
        }
  
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x, self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width + 20 , 21);
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }
        
        if(alMessage.contentType ==  10){
            [self dateTextSetupForALMessage:alMessage withViewSize:viewSize andTheTextSize:theTextSize];
            self.mUserProfileImageView.alpha = 0;
            self.mNameLabel.hidden = YES;
            self.mChannelMemberName.hidden = YES;
            [self.mMessageLabel setUserInteractionEnabled:NO];

        }

        
    }
    else    //Sent Message
    {
        if([ALApplozicSettings getSendMsgColor])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        self.mUserProfileImageView.alpha=0;
        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - 53, 0, 0, 45);
        
        self.mMessageStatusImageView.hidden = NO;
        self.mMessageLabel.text = alMessage.message;
        
        self.mBubleImageView.frame = CGRectMake((viewSize.width - theTextSize.width - 27) , 0 ,theTextSize.width + 18  ,theTextSize.height + 20);
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.mMessageLabel.backgroundColor = [UIColor clearColor];
        self.mMessageLabel.textColor = [UIColor whiteColor];
        self.mMessageLabel.linkTextAttributes = @{
                                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                                  NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleThick]
                                                  };
        

        
        self.mMessageLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 10, 10, theTextSize.width, theTextSize.height);
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - 20, self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, 21);
        
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        
        UIMenuItem *testMenuItem = [[UIMenuItem alloc] initWithTitle:@"Info" action:@selector(msgInfo:)];
        [[UIMenuController sharedMenuController] setMenuItems: @[testMenuItem]];
        [[UIMenuController sharedMenuController] update];
        
        if(alMessage.contentType ==  10){
            [self dateTextSetupForALMessage:alMessage withViewSize:viewSize andTheTextSize:theTextSize];
            self.mMessageStatusImageView.hidden = YES;
        }

    }
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && (alMessage.contentType != 10)) {
        
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue) {
            case DELIVERED_AND_READ :{
                imageName = @"ic_action_read.png";
            }break;
            case DELIVERED:{
                imageName = @"ic_action_message_delivered.png";
            }break;
            case SENT:{
                imageName = @"ic_action_message_sent.png";
            }break;
            default:{
                imageName = @"ic_action_about.png";
            }break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    self.mDateLabel.text = theDate;

    if ([alMessage.message rangeOfString:@"http://"].location != NSNotFound || [alMessage.message rangeOfString:@"www."].location != NSNotFound || [alMessage.message rangeOfString:@"https://"].location != NSNotFound)
    {
        self.mMessageLabel.userInteractionEnabled = YES;
    }
    else
    {
        self.mMessageLabel.userInteractionEnabled = NO;
    }
    
    
    return self;
    
}

-(void)dateTextSetupForALMessage:(ALMessage *)alMessage withViewSize:(CGSize)viewSize andTheTextSize:(CGSize)theTextSize{
    
    [self.mDateLabel setHidden:YES];
    [self.mBubleImageView setHidden:YES];
    [self.mMessageLabel setFrame:CGRectMake(0, 0, viewSize.width, theTextSize.height+10)];
    [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mMessageLabel setText:alMessage.message];
    
    [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
    [self.mMessageLabel setTextColor:[UIColor blackColor]];
    self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
         return (action == @selector(copy:) || action == @selector(delete:)||action == @selector(msgInfo:));
    }
    return (action == @selector(copy:) || action == @selector(delete:));
}

// Default copy method
- (void)copy:(id)sender {
    
    NSLog(@"Copy in ALChatCell, messageId: %@", self.mMessage.message);
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    
    if(self.mMessage.message!=NULL){
        //    [pasteBoard setString:cell.textLabel.text];
        [pasteBoard setString:self.mMessage.message];
    }
    else{
        [pasteBoard setString:@""];
    }
    
}

-(void) delete:(id)sender {
    
    NSLog(@"Delete in ALChatCell pressed");
    
    //UI
    NSLog(@"message to deleteUI %@",self.mMessage.message);
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString* string,NSError* error){
        if(!error ){
            NSLog(@"No Error");
        }
        else{
            NSLog(@"some error");
        }
    }];
    
}

- (void)msgInfo:(id)sender
{
    UIStoryboard* storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *launchChat = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    
    [launchChat setMessage:self.mMessage andHeaderHeight:msgFrameHeight  withCompletionHandler:^(NSError *error) {
        
        if(!error){
            
            [self.delegate loadView:launchChat];
        }
    }];
}


@end
