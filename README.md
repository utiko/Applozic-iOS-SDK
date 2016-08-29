# Applozic-iOS-SDK
iOS Chat SDK


### Overview         

Open source iOS Chat and Messaging SDK that lets you add real time messaging in your mobile (android, iOS) applications and website.

Signup at https://www.applozic.com/signup.html to get the application key.

Works for both Objective-C and Swift.

It is a light weight Objective-C Chat and Messenger SDK.

Applozic One to One and Group Chat SDK

Documentation: https://www.applozic.com/docs/ios-chat-sdk.html

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




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Dashboard.png)         



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

[**ALChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/ALChatManager.h)        

[**ALChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/ALChatManager.m)  

Change applicationID in ALChatManager and you are ready to launch your chat from your controller :)

Launch your chat

```
//Replace with your application key in ALChatManager.h

#define APPLICATION_ID @"applozic-sample-app" 


//Launch your Chat from your controller.
 ALChatManager * chatManager = [[ALChatManager alloc]init];
    [chatManager launchChat:<yourcontrollerReference> ];

```

Detail about user creation and registraion:


**PUSH NOTIFICATION REGISTRATION AND HANDLING **

**a ) Send device token to applozic server:**

In your AppDelegate’s **didRegisterForRemoteNotificationsWithDeviceToken **method  send device registration to applozic server after you get deviceToken from APNS. Sample code is as below:             

**Swift**
```
func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

    let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )

    let deviceTokenString: String = ( deviceToken.description as NSString )
    .stringByTrimmingCharactersInSet( characterSet )
    .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String

    print( deviceTokenString )

    if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString){

        let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        alRegisterUserClientService.updateApnDeviceTokenWithCompletion(deviceTokenString, withCompletion: { (response, error) in
            print (response)
        })
    }
}
```


**Objective-C**      
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

**Swift**
```
func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

    let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
    let applozicProcessed = alPushNotificationService.processPushNotification(userInfo, updateUI: application.applicationState == UIApplicationState.Active) as Bool

    //IF not a appplozic notification, process it

    if (applozicProcessed) {

        //Note: notification for app
    }

}
```

**Objective-C**      
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

**Swift**
```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

// Override point for customization after application launch.
let alApplocalNotificationHnadler : ALAppLocalNotifications =  ALAppLocalNotifications.appLocalNotificationHandler();
alApplocalNotificationHnadler.dataConnectionNotificationHandler();

    if (launchOptions != nil)
    {
    let dictionary = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary

        if (dictionary != nil)
        {
            print("launched from push notification")
            let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()

            let appState: NSNumber = NSNumber(int: 0)
            let applozicProcessed = alPushNotificationService.processPushNotification(launchOptions,updateUI:appState)
            if (applozicProcessed) {
                return true;
            }
        }
    }

return true
}

```

**Objective-C**    
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

__Version 3.3__

* Dynamic Application
* Group Delete Feature
* Contact and UI Bug fixes

__Version 3.2.1__

* Context Chat Display Name fixes
* User's email for Registration fixes

__Version 3.2__

* Group Image Upload on creation
* Login User Profile and Receiver User Information Updates
* Typing Indicator in group
* APNs enhancements
* Image Sharing

__Version 3.0__

 * HyperLink Underline fixes(iOS < 9)
 * Typing Indicator UI fixes
 * Send/Receive messages text color settings
 * No conversation Label added if chat is empty in individual chat
 * App icon and APNs tap action fixes 

__Version 2.8__

 * Calling option with option to enable/disable this feature
 * SMS fallback functionality if reciever/sender do not reads thier messages within specific time period
  
 (For above two features to work, User contacts should be registered with their phone numbers)
 * Enable/disable Context-based-chat's view

__Version 2.7__

 * Group-Exit, Add-Member UI updates
 * UserTypeId parameters added for registration
 * Group sync call bug fixes
 * Block user handled even if other’s app is killed
 * Online/Offline UI updates for block user
 * User’s display name updating
 * Chat Background wallpaper
 * Hidden Messages
 * Custom Messsages (Custom Layout)
 * Contact List with Online Users with configurable limit
 * New Group Addition bug fixes
 * Contact Image bug fixes

__Version 2.6__
 * Settings to toggle buttons:
    * Group-Exit Button
    * Group-Member-Add Button
    * Group-Member-Remove Button

__Version 2.5__
 * Typing indicator UI fixes
 * Block user UI bug fixes
 * First time messages to new user bug fixes
 * Location bug fixes
 * Chat list user profile view fixes
 * Contact list enhancement
 * App module
 * Display name & group name bug fixes
 * Notification bug fixes
 * Multiple attachment with configurable limit

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
 
For more details, visit: https://www.applozic.com/docs/ios-chat-sdk.html

###Sample code in Objective-C to build messenger and chat app

https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sample-with-framework

###Sample code in Swift to build messenger and chat app
https://www.applozic.com/blog/add-applozic-chat-framework-ios/

###How to add source code in your xcode project
https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sampleapp-swift


##Help

We provide support over at [StackOverflow] (http://stackoverflow.com/questions/tagged/applozic) when you tag using applozic, ask us anything.

Applozic is the best ios chat sdk for instant messaging, still not convinced? Write to us at github@applozic.com and we will be happy to schedule a demo for you.

##Github projects

Android Chat SDK https://github.com/AppLozic/Applozic-Android-SDK

Web Chat Plugin https://github.com/AppLozic/Applozic-Web-Plugin

iOS Chat SDK https://github.com/AppLozic/Applozic-iOS-SDK
