# Applozic-iOS-SDK
iOS Chat SDK


### Overview         

Open source iOS Chat and Messaging SDK that lets you add real time messaging in your mobile (android, iOS) applications and website.

Signup at https://www.applozic.com/signup.html to get the application key.

Works for both Objective-C and Swift.

It is a light weight Objective-C Chat and Messenger SDK.

Features:


 One to one and Group Chat
 
 Image capture
 
 Photo sharing

 Location sharing
 
 Push notifications
 
 In-App notifications
 
 Online presence
 
 Last seen at 
 
 Unread message count
 
 Typing indicator
 
 Message sent, delivery report
 
 Offline messaging
 
 Multi Device sync
 
 Application to user messaging
 
 Customized chat bubble
 
 UI Customization Toolkit
 
 Cross Platform Support (iOS, Android & Web)


### Getting Started                 


**Create your Application**

a )  [**Sign up**](https://www.applozic.com/signup.html?utm_source=ios&utm_medium=github) with applozic to get your application key.

b ) Once you signed up create your Application with required details on admin dashboard. Upload your push-notification certificate to our portal to enable real time notification.         




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-dashboard-blank-page.png)         



c) Once you create your application you can see your application key listed on admin dashboard. Please use same application key explained in further steps.          




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-dashboard-content-page.png)         





**Installing the iOS SDK** 

**ADD APPLOZIC FRAMEWORK **
Clone or download the SDK (https://github.com/AppLozic/Applozic-iOS-SDK)
Get the latest framework "Applozic.framework" from Applozic github repo [**sample project**](https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sampleapp)

**Add framework to your project:**

i ) Paste Applozic framework to root folder of your project. 
ii ) Go to Build Phase. Expand  Embedded frameworks and add applozic framework.         




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-adding-applozic-framework.png)        


**Quickly Launch your chat**


You can test your chat quickly by adding below .h and .m file to your project.

[**DemoChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/DemoChatManager.h)        

[**DemoChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/DemoChatManager.m)  

Change applicationID in DemoChatManager and you are ready to launch your chat from your controller :)

Launch your chat

```
//Replace with your application key in DemoChatManager.h

#define APPLICATION_ID @"applozic-sample-app" 


//Launch your Chat from your controller.
 DemoChatManager * demoChatManager = [[DemoChatManager alloc]init];
    [demoChatManager launchChat:<yourcontrollerReference> ];

```

Detail about user creation and registraion:


**PUSH NOTIFICATION REGISTRATION AND HANDLING **

**a ) Send device token to applozic server:**

In your AppDelegate’s **didRegisterForRemoteNotificationsWithDeviceToken **method  send device registration to applozic server after you get deviceToken from APNS. Sample code is as below:             




** Objective-C **      
```
 - (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)
   deviceToken       
   {                
  
    const unsigned *tokenBytes = [deviceToken bytes];            
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",                 
    ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),             
    ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),             
    ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];              
    
    NSString *apnDeviceToken = hexToken;            
    NSLog(@"apnDeviceToken: %@", hexToken);                  
 
   //TO AVOID Multiple call to server check if previous apns token is same as recent one, 
   if different call app lozic server.           

    if (![[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:apnDeviceToken])              
    {                         
       ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];          
       [registerUserClientService updateApnDeviceTokenWithCompletion
       :apnDeviceToken withCompletion:^(ALRegistrationResponse
       *rResponse, NSError *error)       
     {              
       if (error)         
          {          
             NSLog(@"%@",error);             
            return ;           
          }              
    NSLog(@"Registration response from server:%@", rResponse);                         
    }]; } }                                 

```


**b) Receiving push notification:**

Once your app receive notification, pass it to applozic handler for applozic notification processing.             


** Objective-C **      
  ```
  - (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)dictionary         
  {            
   NSLog(@"Received notification: %@", dictionary);           
   
   ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];        
   BOOL applozicProcessed = [pushNotificationService processPushNotification:dictionary updateUI:
   [[UIApplication sharedApplication]     applicationState] == UIApplicationStateActive];             
  
    //IF not a appplozic notification, process it            
  
    if (!applozicProcessed)            
      {                
         //Note: notification for app          
    } }                                                           
```


**c) Handling app launch on notification click :**          


** Objective-C **    
```
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions    
  {                     
  // Override point for customization after application launch.                              
  NSLog(@"launchOptions: %@", launchOptions);                  
  if (launchOptions != nil)               
  {             
  NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];         
  if (dictionary != nil)             
    {          
      NSLog(@"Launched from push notification: %@", dictionary);        
      ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];            
      BOOL applozicProcessed = [pushNotificationService processPushNotification:dictionary updateUI:NO];               
  if (!applozicProcessed)                 
     {            
       //Note: notification for app              
     } } }                                   
      return YES;                 
  }                             

```

### Changelog
__Version 2.2__
 * Contact sharing. 
 * Offline message sync.
 * User block/unblock background sync.
 * Background message sync on APNs notification.
 * Delivery reports on background mode.
 * Unread count bug fix.
 * Multi-Receiver APIs.
 * Group UI and API changes
 * Handle operations on no network

__Version 2.1__
 * Read Receipts for Messages
 * Message Information details
 * User Block/Unblock
 * Offline Message Sending for types:
   * Text
   * Location

__Version 2.0__
 * Context-based messaging
 * Group messaging
 * Attachments support
   * Audio messages
   * Video messages
 * Image compression (Configurable)
 
For more details, visit: https://www.applozic.com/developers.html#ios-sdk

###Sample code in Objective-C to build messenger and chat app

https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sample-with-framework

###Sample code in Swift to build messenger and chat app

https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sampleapp-swift


##Help

We provide support over at [StackOverflow] (http://stackoverflow.com/questions/tagged/applozic) when you tag using applozic, ask us anything.

Applozic is the best ios chat sdk for instant messaging, still not convinced? Write to us at github@applozic.com and we will be happy to schedule a demo for you.

##Github projects

Android Chat SDK https://github.com/AppLozic/Applozic-Android-SDK

Web Chat Plugin https://github.com/AppLozic/Applozic-Web-Plugin

iOS Chat SDK https://github.com/AppLozic/Applozic-iOS-SDK
