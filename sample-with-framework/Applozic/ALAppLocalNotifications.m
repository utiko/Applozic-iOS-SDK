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
#import "ALChatViewController.h"
#import "ALMessageDBService.h"
#import "ALMessageService.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageService.h"


@implementation ALAppLocalNotifications{
    NSNumber *updateUI ;
    NSString *alertValue;
}


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thirdPartyNotificationHandler:) name:@"showNotificationAndLaunchChat" object:nil];
    // create a Reachability object for www.google.com
    
    self.googleReach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    self.googleReach.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Block Says Reachable(%@)", reachability.currentReachabilityString];
        // NSLog(@"%@", temp);
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this uses NSOperationQueue mainQueue
        
    };
    
    self.googleReach.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"GOOGLE Block Says Unreachable(%@)", reachability.currentReachabilityString];
        //  NSLog(@"%@", temp);
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this one uses dispatch_async they do the same thing (as above)
        
    };
    
    [self.googleReach startNotifier];
    
    // create a reachability for the local WiFi
    
    self.localWiFiReach = [Reachability reachabilityForLocalWiFi];
    
    // we ONLY want to be reachable on WIFI - cellular is NOT an acceptable connectivity
    self.localWiFiReach.reachableOnWWAN = NO;
    
    self.localWiFiReach.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"LocalWIFI Block Says Reachable(%@)", reachability.currentReachabilityString];
        // NSLog(@"%@", temp);
        
        
    };
    
    self.localWiFiReach.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"LocalWIFI Block Says Unreachable(%@)", reachability.currentReachabilityString];
        
        // NSLog(@"%@", temp);
        
    };
    
    [self.localWiFiReach startNotifier];
    
    // create a Reachability object for the internet
    
    self.internetConnectionReach = [Reachability reachabilityForInternetConnection];
    
    self.internetConnectionReach.reachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@" InternetConnection Says Reachable(%@)", reachability.currentReachabilityString];
        // NSLog(@"%@", temp);
    };
    
    self.internetConnectionReach.unreachableBlock = ^(Reachability * reachability)
    {
        NSString * temp = [NSString stringWithFormat:@"InternetConnection Block Says Unreachable(%@)", reachability.currentReachabilityString];
        //  NSLog(@"%@", temp);
    };
    
    [self.internetConnectionReach startNotifier];
    
}
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if(reach == self.googleReach)
    {
        if([reach isReachable])
        {
            //NSLog(@"========== IF googleReach ============");
        }
        else
        {
            // NSLog(@"========== ELSE googleReach ============");
        }
    }
    else if (reach == self.localWiFiReach)
    {
        if([reach isReachable])
        {
            // NSLog(@"========== IF localWiFiReach ============");
        }
        else
        {
            // NSLog(@"========== ELSE localWiFiReach ============");
        }
    }
    else if (reach == self.internetConnectionReach)
    {
        if([reach isReachable])
        {
             NSLog(@"========== IF internetConnectionReach ============");
            [ALMessageService processLatestMessagesGroupByContact];
            //changes required
        }
        else
        {
            NSLog(@"========== ELSE internetConnectionReach ============");
        }
    }
    
}

// To DISPLAY THE NOTIFICATION ONLY ...from 3rd Party View.
-(void)thirdPartyNotificationHandler:(NSNotification*)notification{
    
    NSLog(@" 3rd Party notificationHandler called .....");
    
    self.contactId = notification.object;
    NSLog(@"Notification Object %@",self.contactId);
    self.dict = notification.userInfo;
    updateUI = [self.dict valueForKey:@"updateUI"];
    NSLog(@"UIDATE UI ALAppNotificaiton %@",updateUI);
    alertValue = [self.dict valueForKey:@"alertValue"];
    NSLog(@"alertValue ALAppLN:>>>%@",alertValue);
    //ALMessageDBService* obj=[[ALMessageDBService alloc] init];
    // [obj fetchAndRefreshQuickConversation];
    
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
    [ALMessageService getLatestMessageForUser:deviceKeyString withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        

        if(updateUI==[NSNumber numberWithBool:NO]){
            NSLog(@"App launched from Background");
            [self thirdPartyNotificationTap:nil]; // Directly launching Chat
            return;
        }
        
        if(updateUI==[NSNumber numberWithBool:YES]){
            
            if(alertValue){
                NSLog(@"App launched from 3rdParty");
                [ALUtilityClass thirdDisplayNotificationTS:alertValue delegate:self];
                //                    [ALUtilityClass thirdDisplayNotification:alertValue delegate:self];
                //                    [ALUtilityClass newDisplayNotificaiton:alertValue delegate:self];
                
                
            }
            else{
                NSLog(@"Nil Alert Value");
            }
        }
        
    }];
    
    
    //    [ALUtilityClass displayNotification:alertValue delegate:self];
}

-(void)thirdPartyNotificationTap:(UIGestureRecognizer*)gestureRecognizer{
    
    ALPushAssist* object=[[ALPushAssist alloc] init];
    
    //for Individual Chat Conversation Opening...
    NSLog(@"Chat Launch Contact ID: %@",self.contactId);
    self.chatLauncher =[[ALChatLauncher alloc]initWithApplicationId:APPLICATION_KEY];
    [self.chatLauncher launchIndividualChat:self.contactId andViewControllerObject:object.topViewController andWithText:nil];
}


-(void)dealloc
{
     NSLog(@"DEALLOC METHOD CALLED");
}

@end