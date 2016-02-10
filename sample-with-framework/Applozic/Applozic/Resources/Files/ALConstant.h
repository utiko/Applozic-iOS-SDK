//
//  ALConstant.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//


//#define KBASE_URL @"https://apps.applozic.com"
#define KBASE_URL @"https://test.applozic.com"
//#define MQTT_URL @"apps.applozic.com"
#define MQTT_URL @"test.applozic.com"

#define MQTT_PORT @"1883"

#define KBASE_FILE_URL @"https://applozic.appspot.com"


#define FORWARD_STATUS @"5"
#define REPLIED_STATUS @"4"
#define DEFAULT_FONT_NAME @"Helvetica-Bold"

#define APPLOZIC_TOPBAR_COLOR @"ApplozicTopbarColor"
#define APPLOZIC_CHAT_BACKGROUND_COLOR @"ApplozicChatBackgroundColor"
#define APPLOZIC_CHAT_FONTNAME @"ApplozicChatFontName"
#define APPLOGIC_TOPBAR_TITLE_COLOR @"ApplozicTopbarTitleColor"
#define APPLOGIC_IMAGEDOWNLOAD_BASEURL @"https://applozic.appspot.com/rest/ws/file"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))
#define IS_STANDARD_IPHONE_6 (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_ZOOMED_IPHONE_6 (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 736.0)
#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 375.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)
#define IS_IPHONE_6 (IS_STANDARD_IPHONE_6 || IS_ZOOMED_IPHONE_6)
#define IS_IPHONE_6_PLUS (IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6_PLUS)