//
//  ALAppLocalNotifications.m
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALAppLocalNotifications.h"
#import "ALChatViewController.h"
#import "ALNotificationView.h"
#import "ALUtilityClass.h"
#import "ALPushAssist.h"
#import "ALMessageDBService.h"
#import "ALMessageService.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageService.h"
#import "ALMessagesViewController.h"


@implementation ALAppLocalNotifications


+(ALAppLocalNotifications *)appLocalNotificationHandler
{
    static ALAppLocalNotifications * localNotificationHandler = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        localNotificationHandler = [[self alloc] init];
        
        
        
        
    });
    
    return localNotificationHandler;
}

-(void)dataConnectionNotificationHandler
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AL_kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thirdPartyNotificationHandler:) name:@"showNotificationAndLaunchChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundBase:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    if([ALUserDefaultsHandler isLoggedIn]){
        
        [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *messageArray, NSError *error) {
            if (error) {
                NSLog(@"ERROR");
            }
            else{
            }
        }];
    }
    
    // create a Reachability object for www.google.com
    
    self.googleReach = [ALReachability reachabilityWithHostname:@"www.google.com"];
    
    self.googleReach.reachableBlock = ^(ALReachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Block Says Reachable(%@)", reachability.currentReachabilityString];
        // NSLog(@"%@", temp);
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this uses NSOperationQueue mainQueue
        
    };
    
    self.googleReach.unreachableBlock = ^(ALReachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Block Says Unreachable(%@)", reachability.currentReachabilityString];
        //  NSLog(@"%@", temp);
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this one uses dispatch_async they do the same thing (as above)
        
    };
    
    [self.googleReach startNotifier];
    
    // create a reachability for the local WiFi
    
    self.localWiFiReach = [ALReachability reachabilityForLocalWiFi];
    
    // we ONLY want to be reachable on WIFI - cellular is NOT an acceptable connectivity
    self.localWiFiReach.reachableOnWWAN = NO;
    
    self.localWiFiReach.reachableBlock = ^(ALReachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"LocalWIFI Block Says Reachable(%@)", reachability.currentReachabilityString];
        // NSLog(@"%@", temp);
        
        
    };
    
    self.localWiFiReach.unreachableBlock = ^(ALReachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"LocalWIFI Block Says Unreachable(%@)", reachability.currentReachabilityString];
        
        // NSLog(@"%@", temp);
        
    };
    
    [self.localWiFiReach startNotifier];
    
    // create a Reachability object for the internet
    
    self.internetConnectionReach = [ALReachability reachabilityForInternetConnection];
    
    self.internetConnectionReach.reachableBlock = ^(ALReachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@" InternetConnection Says Reachable(%@)", reachability.currentReachabilityString];
        // NSLog(@"%@", temp);
    };
    
    self.internetConnectionReach.unreachableBlock = ^(ALReachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"InternetConnection Block Says Unreachable(%@)", reachability.currentReachabilityString];
        //  NSLog(@"%@", temp);
    };
    
    [self.internetConnectionReach startNotifier];
    
}
-(void)reachabilityChanged:(NSNotification*)note
{
    ALReachability * reach = [note object];
    
    if(reach == self.googleReach)
    {
        if([reach isReachable])
        {
            NSLog(@"========== IF googleReach ============");
        }
        else
        {
            NSLog(@"========== ELSE googleReach ============");
        }
    }
    else if (reach == self.localWiFiReach)
    {
        if([reach isReachable])
        {
            NSLog(@"========== IF localWiFiReach ============");
        }
        else
        {
            NSLog(@"========== ELSE localWiFiReach ============");
        }
    }
    else if (reach == self.internetConnectionReach)
    {
        if([reach isReachable])
        {
            NSLog(@"========== IF internetConnectionReach ============");
            
            //            [ALMessageService processLatestMessagesGroupByContact];
            [ALMessageService processPendingMessages];
        }
        else
        {
            NSLog(@"========== ELSE internetConnectionReach ============");
        }
    }
    
}


//receiver
- (void)appWillEnterForegroundBase:(NSNotification *)notification {
    
    //Works in 3rd Party borders..
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
    [ALMessageService getLatestMessageForUser:deviceKeyString withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        if (error) {
            NSLog(@"ERROR");
        }
        else{
        }
    }];
}

#pragma mark - Third Party Notificaiton Handlers
//===================================================

-(void)thirdPartyNotificationHandler:(NSNotification*)notification{
    
    self.contactId = notification.object;
    self.dict = notification.userInfo;
    NSNumber * updateUI = [self.dict valueForKey:@"updateUI"];
    NSString * alertValue = [self.dict valueForKey:@"alertValue"];
    
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
    [ALMessageService getLatestMessageForUser:deviceKeyString
                               withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        
//      Directly opening chat when app coming from background/inactive state
        if(updateUI==[NSNumber numberWithBool:NO]){
            [self thirdPartyNotificationTap:self.contactId];
            return;
        }

//      Shows notfication view on third party views
        if(updateUI==[NSNumber numberWithBool:YES]){

            if(alertValue){
                [ALUtilityClass foreignViewNotification:alertValue andForContactId:self.contactId delegate:self];
            }
            else{
                NSLog(@"Nil Alert Value");
            }
        }
        
    }];
    
}

//  Notification Tap Handler
-(void)thirdPartyNotificationTap:(NSString *) contactId{
    
    ALPushAssist* object=[[ALPushAssist alloc] init];
    //for Individual Chat Conversation Opening...
    if(!object.isChatViewOnTop){
        self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_KEY];
        [self.chatLauncher launchIndividualChat:contactId andViewControllerObject:object.topViewController andWithText:nil];
    }
    
}



-(void)dealloc
{
    NSLog(@"DEALLOC METHOD CALLED");
}



@end
