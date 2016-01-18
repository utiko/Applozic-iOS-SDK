//
//  ALUtilityClass.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALChatLauncher.h"
#import "ALChatLauncher.h"

@interface ALUtilityClass : NSObject

+ (NSString *) formatTimestamp:(NSTimeInterval) timeInterval toFormat:(NSString *) forMatStr;

+ (NSString *)generateJsonStringFromDictionary:(NSDictionary *)dictionary;

+(UIColor*)colorWithHexString:(NSString*)hex;

+(id)parsedALChatCostomizationPlistForKey:(NSString *)key;

+ (BOOL)isToday:(NSDate *)todayDate;

+ (NSString*) fileMIMEType:(NSString*) file;

+(CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize;

+(void)displayToastWithMessage:(NSString *)toastMessage;

+(void)thirdDisplayNotification:(NSString *)toastMessage delegate:(id)delegate;
+(void)thirdDisplayNotificationTS:(NSString *)toastMessage andForContactId:(NSString *)contactId  delegate:(id)delegate;
+(void)localNotification:(NSString *)toastMessage;
+(void)newDisplayNotificaiton:(NSString *)toastMessage delegate:(id)delegate;



+(NSString *)getFileNameWithCurrentTimeStamp;
+(UIImage *)getImageFromFramworkBundle:(NSString *) UIImageName;


@end