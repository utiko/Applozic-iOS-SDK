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

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"


@implementation ALChatCell


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
        
        self.status = @"";
        self.string = @"Delivered ";
        
        self.mBubleImageView = [[UIImageView alloc] init];
        
//        self.mBubleImageView.frame = CGRectMake(5, 5, 100, 44);
        
    //    self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.origin.x+self.mUserProfileImageView.frame.size.width+5 , 5, self.frame.size.width-110, self.frame.size.width-110);
        
        self.mBubleImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.mBubleImageView];

        self.mMessageLabel =[[ALUITextView alloc] init];
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
        self.mBubleImageView.layer.cornerRadius = 5;
        
        self.mMessageLabel.userInteractionEnabled=NO;
        
        [self.contentView addSubview:self.mMessageLabel];

        self.mChannelMemberName = [[UILabel alloc] init];
        self.mChannelMemberName.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE];
        self.mChannelMemberName.textColor = [UIColor blackColor];
        self.mChannelMemberName.backgroundColor = [UIColor clearColor];
     //   [self.contentView addSubview:self.mChannelMemberName];

        self.mDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 25)];
        
        self.mDateLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE];
        
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        self.mDateLabel.numberOfLines = 1;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0  alpha:1];
        
        [self.contentView addSubview:self.mDateLabel];

        
        self.mMessageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mDateLabel.frame.origin.x+self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20)];
        
        self.mMessageStatusImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.mMessageStatusImageView.backgroundColor = [UIColor clearColor];
        
       // [self.contentView addSubview:self.mMessageStatusImageView];
        
        self.contentView.userInteractionEnabled=YES;

    }
    
    
    return self;
    
}


-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize {
    
    self.mUserProfileImageView.alpha=1;
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    self.mMessage = alMessage;
    
    CGSize theTextSize = [self getSizeForText:alMessage.message maxWidth:viewSize.width-115 font:self.mMessageLabel.font.fontName fontSize:self.mMessageLabel.font.pointSize];
    
    CGSize theDateSize = [self getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    [self.mBubleImageView setHidden:NO];
    [self.mDateLabel setHidden:NO];
    [self.mMessageLabel setTextAlignment:NSTextAlignmentLeft];
    [self.mChannelMemberName setHidden:YES];
    //MT_INBOX(Short.valueOf("4")),
    // MT_OUTBOX(Short.valueOf("5")),
    if([alMessage.type isEqualToString:@"100"])
    {
        [self.mDateLabel setHidden:YES];
        [self.mBubleImageView setHidden:YES];
        [self.mMessageLabel setFrame:CGRectMake(0, 0, viewSize.width, theTextSize.height+10)];
        [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mMessageLabel setText:alMessage.message];
        
        [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
        [self.mMessageLabel setTextColor:[UIColor blackColor]];
        self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);
    }
    else if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT]/*[alMessage.type isEqualToString:@"4"]*/) { //Recieved Message
        
        [self.mChannelMemberName setHidden:NO];
        [self.contentView bringSubviewToFront:self.mChannelMemberName];
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 45, 45);
        }
        
        if([ALApplozicSettings getReceiveMsgColour])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColour];
            self.mMessageLabel.backgroundColor = [ALApplozicSettings getReceiveMsgColour];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
       
        
        
        self.mUserProfileImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"];
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13, 0, theTextSize.width + 18 , theTextSize.height + 20);
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;
        
        self.mMessageLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 10 , 10, theTextSize.width, theTextSize.height);
        self.mMessageLabel.textColor = [UIColor grayColor];
        
        self.mMessageLabel.linkTextAttributes = @{
                                                  NSForegroundColorAttributeName : [UIColor grayColor],
                                                  NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleThick]
                                                  };
        self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x, self.mBubleImageView.frame.origin.y + 5, self.mBubleImageView.frame.size.width, 20);
        [self.mChannelMemberName setText:alMessage.to];
        if(alMessage.contentType == 3)
        {

            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[alMessage.message dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            self.mMessageLabel.attributedText = attributedString;
        }
        else
        {
            self.mMessageLabel.text = alMessage.message;
        }

        //        self.mDateLabel.frame = CGRectMake(self.mMessageLabel.frame.origin.x , self.mMessageLabel.frame.origin.y+ self.mMessageLabel.frame.size.height + 3, theDateSize.width , 21);
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x, self.mMessageLabel.frame.origin.y + self.mBubleImageView.frame.size.height - 10, theDateSize.width + 20 , 21);
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x+self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        
        self.mMessageStatusImageView.alpha = 0;
        
        ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
       
        if (alContact.localImageResourceName)
        {
            self.mUserProfileImageView.image = [ALUtilityClass getImageFromFramworkBundle:alContact.localImageResourceName];
            
        }
        else  if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            self.mUserProfileImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"];
        }

    }
    else    //Sent Message
    {
        if([ALApplozicSettings getSendMsgColour])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColour];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        self.mUserProfileImageView.alpha=0;
//        self.mUserProfileImageView.frame = CGRectMake(viewSize.width-53, 0, 45, 45);
         self.mUserProfileImageView.frame = CGRectMake(viewSize.width-53, 0, 0, 45);
        
//        int imgVwWidth = theTextSize.width>150?theTextSize.width+14:150;
//        
//        int imgVwHeight = theTextSize.height+21>45?theTextSize.height+21+10:45;
        
 //       self.mBubleImageView.frame = CGRectMake(viewSize.width - imgVwWidth -10 , 0 ,imgVwWidth  ,imgVwHeight);
        
         self.mMessageLabel.text = alMessage.message;
        
        self.mBubleImageView.frame = CGRectMake((viewSize.width - theTextSize.width - 27) , 0 ,theTextSize.width + 18  ,theTextSize.height + 20);
        
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;

        
        
        self.mMessageLabel.backgroundColor = [UIColor clearColor];
        self.mMessageLabel.textColor = [UIColor whiteColor];
        
        self.mMessageLabel.linkTextAttributes = @{
                                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                                  NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleThick]
                                                  };
        
//        self.mBubleImageView.backgroundColor = [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1];
        
        self.mMessageLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 10, 10, theTextSize.width, theTextSize.height);
        
//        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 8, self.mMessageLabel.frame.origin.y + self.mMessageLabel.frame.size.height +3 , theDateSize.width, 21);
        
        if(alMessage.delivered == YES){
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - (self.string.length + theDateSize.width + 45) , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, self.string.length + theDateSize.width + 50, 21);
        }
        else{
            self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) -theDateSize.width  , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width + 20, 21);
        }
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x+self.mDateLabel.frame.size.width+10, self.mDateLabel.frame.origin.y, 20, 20);
        
    }
    
    self.status = @"";

    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]/*[alMessage.type isEqualToString:@"5"]*/) {
        self.mMessageStatusImageView.alpha =1;
        if(alMessage.delivered == YES) {
            self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_message_delivered.png"];
            self.status = @"Delivered ";
        }
        else if(alMessage.sent == YES){
            self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_message_sent.png"];
        }else{
            self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_about.png"];
        }
    }
    
   
    if(![self.status isEqualToString:@""]){
        self.mDateLabel.text = [self.status stringByAppendingString:theDate];
    }
    else{
    self.mDateLabel.text = theDate;
    }
    
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}


- (CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize {
    
    CGSize constraintSize;
    
    constraintSize.height = MAXFLOAT;
    
    constraintSize.width = width;
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    
    CGSize stringSize = frame.size;
    
    return stringSize;
}


-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
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
    
    //db
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    [dbService deleteMessageByKey:self.mMessage.key];

    
    //UI
    NSLog(@"message to deleteUI %@",self.mMessage.message);
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:[NSString stringWithFormat:@"%ld",self.mMessage.messageId] andContactId:self.mMessage.contactIds withCompletion:^(NSString* string,NSError* error){
        if(!error ){
            NSLog(@"No Error");
        }
        else{
            NSLog(@"some error");
        }
    }];
    
}


@end
