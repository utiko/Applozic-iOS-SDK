//
//  ALUtilityClass.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALUtilityClass : NSObject

+ (NSString *) formatTimestamp:(NSTimeInterval) timeInterval toFormat:(NSString *) forMatStr;

+ (NSString *)generateJsonStringFromDictionary:(NSDictionary *)dictionary;

+(UIColor*)colorWithHexString:(NSString*)hex;

+(id)parsedALChatCostomizationPlistForKey:(NSString *)key;

+ (BOOL)isToday:(NSDate *)todayDate;

+ (NSString*) fileMIMEType:(NSString*) file;

+(CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize;

+(void)displayToastWithMessage:(NSString *)toastMessage;

+(void)displayNotification:(NSString *)toastMessage delegate:(id)delegate;
+(NSString *)getFileNameWithCurrentTimeStamp;

@end
