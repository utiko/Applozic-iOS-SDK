//
//  ALUtilityClass.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALUtilityClass.h"
#import "ALConstant.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALChatViewController.h"
#import "ALAppLocalNotifications.h"
#import <QuartzCore/QuartzCore.h>
#import "TSMessage.h"
#import "TSMessageView.h"
#import "ALPushAssist.h"
#import "ALAppLocalNotifications.h"


@implementation ALUtilityClass

+ (NSString *) formatTimestamp:(NSTimeInterval) timeInterval toFormat:(NSString *) forMatStr
{
    
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];
    [formatter setDateFormat:forMatStr];
    formatter.timeZone = [NSTimeZone localTimeZone];
    
    NSString * dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        
    return dateStr;
    
}

+ (NSString *)generateJsonStringFromDictionary:(NSDictionary *)dictionary {
 
    NSString *jsonString = nil;
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
    
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *colorString = [[hex stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    NSString *cString = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(id)parsedALChatCostomizationPlistForKey:(NSString *)key {
    
    id value = nil;
    
    NSDictionary *values = [ALUtilityClass dictionary];
    
    if ([key isEqualToString:APPLOZIC_TOPBAR_COLOR]) {
        NSString *color= [values valueForKey:APPLOZIC_TOPBAR_COLOR];
        if (color) {
            value = [ALUtilityClass colorWithHexString:color];
        }
    }else if ([key isEqualToString:APPLOZIC_CHAT_BACKGROUND_COLOR]) {
        NSString *color= [values valueForKey:APPLOZIC_CHAT_BACKGROUND_COLOR];
        if (color) {
            value = [ALUtilityClass colorWithHexString:color];
        }
    }else if ([key isEqualToString:APPLOZIC_CHAT_FONTNAME]) {
        
        value = [values valueForKey:APPLOZIC_CHAT_FONTNAME];
    }else if ([key isEqualToString:APPLOGIC_TOPBAR_TITLE_COLOR]){
        NSString *color = [values valueForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
        if (color) {
            value = [ALUtilityClass colorWithHexString:color];
        }
    }
    return value;
}

+ (NSDictionary *)dictionary {
    static NSDictionary *parsedDict = nil;
    if (parsedDict == nil) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ALChatCostomization" ofType:@"plist"];
        parsedDict=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return parsedDict;
}

+ (BOOL)isToday:(NSDate *)todayDate {
    
    BOOL result = NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:todayDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        //do stuff
        result = YES;
    }
    return result;
}

+ (NSString*) fileMIMEType:(NSString*) file {
    NSString *mimeType = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:file] && [file pathExtension]){
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        if(MIMEType){
            mimeType = [NSString stringWithString:(__bridge NSString *)(MIMEType)];
            CFRelease(MIMEType);
        }
    }
    
    return mimeType;
}

+(CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize {
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

+(void)displayToastWithMessage:(NSString *)toastMessage
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        UILabel *toastView = [[UILabel alloc] init];
        toastView.text = toastMessage;
        //toastView.font = @"Helvetica-Bold";
        //toastView.textColor = [MYUIStyles getToastTextColor];
        toastView.backgroundColor = [UIColor whiteColor];
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width/2.0, 75.00);
        toastView.layer.cornerRadius = 10;
        toastView.layer.masksToBounds = YES;
        toastView.center = keyWindow.center;
        
        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 3.0f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             toastView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [toastView removeFromSuperview];
                         }
         ];
    }];
}



+(void)thirdDisplayNotificationTS:(NSString *)toastMessage andForContactId:(NSString *)contactId delegate:(id)delegate{
    
    //3rd Party View is Opened.........
    
    ALPushAssist* top=[[ALPushAssist alloc] init];
    NSLog(@"DELEGATE %@",delegate);
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];

    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];

    [TSMessage showNotificationInViewController:top.topViewController
                                            title:@"Applozic"
                                       subtitle:[NSString stringWithFormat:@"%@",toastMessage]
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:^(void){
        
                                           
                                           [delegate thirdPartyNotificationTap1:contactId];

        
    }buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
    
}




+(void)thirdDisplayNotification:(NSString *)toastMessage delegate:(id)delegate
{
    
    // For 3rd Party Notification Show.....
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        keyWindow.opaque=NO;
        
        UILabel *toastView = [[UILabel alloc] init];

        
        toastView.text = toastMessage;
        toastView.backgroundColor = [UIColor grayColor];
        toastView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.9];
        toastView.textColor = [UIColor whiteColor];
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.frame = CGRectMake(0.0, -75.00, keyWindow.frame.size.width, 75.00);
        toastView.layer.cornerRadius = 0;
        toastView.userInteractionEnabled = YES;
        toastView.font=[UIFont boldSystemFontOfSize:16];
        
        UIImage* img=[[UIImage alloc] init];
        img=[ALUtilityClass getImageFromFramworkBundle:@"NotificationIcon.png"];
        
        UIImageView* dp=[[UIImageView alloc] initWithImage:img];
        [dp setFrame:CGRectMake(toastView.frame.origin.x+10, toastView.frame.origin.y+10, img.size.width, img.size.height)];
        [toastView addSubview:dp];
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(thirdPartyNotificationTap:)];
        [toastView addGestureRecognizer:tapGesture];

        [keyWindow addSubview:toastView];
        [keyWindow bringSubviewToFront:toastView];
    
//      [keyWindow bringSubviewToFront:dp];

        //Timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(TimerCount) userInfo:nil repeats: NO];
        
        [UIView animateWithDuration:0.5 animations:^{
            // set new position of label which it will animate to
            toastView.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width, 75.00);
        }];
        
        //Action Event
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
          
            [UIView animateWithDuration:0.5 animations:^{
                toastView.frame = CGRectMake(0.0, -75.00, keyWindow.frame.size.width, 75.00);
            }];
//            [toastView removeFromSuperview];
        });

    }];
}


+(void)localNotification:(NSString *)toastMessage{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:7];
    notification.alertBody = toastMessage;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber =0;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+(void)newDisplayNotificaiton:(NSString *)toastMessage delegate:(id)delegate
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        UIView* toastView=[[UIView alloc] init];
        toastView.frame=CGRectMake(0.0, 0.0, keyWindow.frame.size.width, 102.00);
        toastView.userInteractionEnabled = YES;
        toastView.layer.cornerRadius=0;
        [toastView setBackgroundColor:[UIColor grayColor]];
        
        UILabel* message=[[UILabel alloc] init];
        message.text=toastMessage;
        message.backgroundColor=[UIColor clearColor];
        message.font=[UIFont boldSystemFontOfSize:16];
        message.userInteractionEnabled=YES;
        message.textColor=[UIColor whiteColor];
        [message drawTextInRect:CGRectMake(93, 8, 113, 36)];
        
        
        
        UIImageView* dpIcon=[[UIImageView alloc] init];
        dpIcon.image=[UIImage imageNamed:@"online_show.png"];
        [dpIcon setFrame:CGRectMake(28, 14, 42, 42)];
        dpIcon.layer.cornerRadius=dpIcon.frame.size.height/2;
        dpIcon.clipsToBounds=YES;
        
        
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(thirdPartyNotificationTap:)];
        [message addGestureRecognizer:tapGesture];
        [toastView addGestureRecognizer:tapGesture];
        
        [toastView addSubview:dpIcon];
        [toastView addSubview:message];
        [toastView bringSubviewToFront:dpIcon];
        [toastView bringSubviewToFront:message];
    

        [keyWindow addSubview:toastView];
        [keyWindow bringSubviewToFront:toastView];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toastView removeFromSuperview];});
    }];

}

+(NSString *)getFileNameWithCurrentTimeStamp{
   

    NSString *resultString = [@"IMG-" stringByAppendingString: @([[NSDate date] timeIntervalSince1970]).stringValue];
    return resultString;
}


+(UIImage *)getImageFromFramworkBundle:(NSString *) UIImageName{
    
    NSBundle * bundle = [NSBundle bundleForClass:ALUtilityClass.class];
    UIImage *image = [UIImage imageNamed:UIImageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

@end
