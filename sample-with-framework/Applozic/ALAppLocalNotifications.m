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

// To DISPLAY THE NOTIFICATION ONLY ...from 3rd Party View.
-(void)thirdPartyNotificationHandler:(NSNotification*)notification{
    
    NSLog(@" 3rd Party notificationHandler called .....");
    
    NSArray *needleArr = [notification.object componentsSeparatedByString:@":"];
    NSNumber* groupId;

    if(needleArr.count>1){
        NSString *groupIdString = [notification.object componentsSeparatedByString:@":"][1];
//        groupIdString=[groupIdString componentsSeparatedByString:@":"][0];
        groupId=[NSNumber numberWithInt:groupIdString.intValue];
    }
    else{
        groupId=nil;
        //TO DO: Set groupId: nil
    }
    self.contactId = notification.object;
    self.dict = notification.userInfo;
    NSNumber * updateUI = [self.dict valueForKey:@"updateUI"];
    NSString * alertValue = [self.dict valueForKey:@"alertValue"];
    
    //NSLog(@"needle %@",needle);
    
    NSLog(@"Notification Dictionary %@ and notificaiotn Object%@",self.dict,notification.object);
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
    [ALMessageService getLatestMessageForUser:deviceKeyString withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        
        
        if(updateUI==[NSNumber numberWithBool:NO]){
            NSLog(@"App launched from Background....Directly opening view from %@",self.dict);
            [self thirdPartyNotificationTap1:self.contactId withGroupId:groupId]; // Directly launching Chat
            return;
        }
        
        if(updateUI==[NSNumber numberWithBool:YES]){
            
            if(alertValue){
                NSLog(@"App launched from 3rdParty for c");
                NSLog(@"posting to notification....%@",notification.userInfo);
                [ALUtilityClass thirdDisplayNotificationTS:alertValue andForContactId:self.contactId withGroupId:groupId delegate:self];
            }
            else{
                NSLog(@"Nil Alert Value");
            }
        }
        
    }];
    
    
    //    [ALUtilityClass displayNotification:alertValue delegate:self];
}
-(void)thirdPartyNotificationTap1:(NSString *) contactId withGroupId:(NSNumber*) groupID{ //:(UIGestureRecognizer*)gestureRecognizer
    
    ALPushAssist* object=[[ALPushAssist alloc] init];
    //for Individual Chat Conversation Opening...
    NSLog(@"Chat Launch Contact ID: %@",self.contactId);
    //Check if this view is there or not ..if there just call fetchAnd refresh...
    if(!object.isChatViewOnTop){
        self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_KEY];
        [self.chatLauncher launchIndividualChat:contactId withGroupId:groupID andViewControllerObject:object.topViewController andWithText:nil];
    }
    
}



-(void)dealloc
{
    NSLog(@"DEALLOC METHOD CALLED");
}



@end
