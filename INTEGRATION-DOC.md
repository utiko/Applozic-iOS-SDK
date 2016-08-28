**Integrate using:** 

1. [**Objective-C**](https://www.applozic.com/docs/ios-chat-sdk.html#objective-c)
2. [**Swift**](https://www.applozic.com/docs/ios-chat-sdk.html#swift)

###Objective-C

####Step 1: Download Chat SDK

**ADD APPLOZIC FRAMEWORK**

Download Applozic Chat latest framework [**here**](https://github.com/AppLozic/Applozic-iOS-SDK/raw/master/Frameworks) and add it to your project.

You can download Sample Chat app code (https://github.com/AppLozic/Applozic-iOS-SDK)  [**sample project**](https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sampleapp) for more reference.


**Add framework to your project:**

i ) Paste Applozic framework to root folder of your project. 

ii ) Go to Build Phase. 

Expand Embedded frameworks and add applozic framework.         


![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-adding-applozic-framework.png)        


####Step 2:  Login/Register User
Applozic will create a new user if the user doesn't exists. userId is the unique identifier for any user, it can be anything like email, phone number or uuid from your database.


i) Add Helper Classes:

Download ALChatManager.h and ALChatManager.m file and add to your project.

[**ALChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sample-with-framework/applozicdemo/ALChatManager.h)        

[**ALChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sample-with-framework/applozicdemo/ALChatManager.m)  

Change value of applicationID in ALChatManager.h with the [Applozic Application Key](https://www.applozic.com/docs/ios-chat-sdk.html#first-level), fill your logged-in user detail and you are ready to launch your chat from your controller.


ii) Login/Register User:

Convenient methods are present in ALChatManager.m to register user with applozic. For simple user registration in background, you can use below method:

```
  ALUser *user = [[ALUser alloc] init];
  [user setUserId:@"testUser"]; //NOTE : +,*,? are not allowed chars in userId.
  [user setDisplayName:@"Applozic Test"]; // Display name of user 
  [user setContactNumber:@""];// formatted contact no
  [user setimageLink:@"user_profile_image_link"];// User's profile image link.
```

```
 -(void)registerUser:(ALUser *)alUser;

```
For performing some action just after user registration, ue the below method:

```
-(void)registerUserWithCompletion:(ALUser *)alUser withHandler:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion
```
For example, if your very first screen of app is chat screen, you can launch chatlist on success of registration. 



####Step 3: Initiate Chat

1) Launch chat list screen:

```
-(void)launchChat: (UIViewController *)fromViewController; //Use this method to launch chat list
   
   //Example: 
    ALChatManager * chatManager = [[ALChatManager alloc] init];
    [chatManager launchChat:<Your Controller>];
```

2) Launch chat with specific user:

```
// Individual chat list launch for group or user with display name

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController;

//Example:
  NSString * userIdOfReceiver =  @"receiverUserId";
  ALChatManager * chatManager = [[ALChatManager alloc] init];
  [chatManager launchChatForUserWithDisplayName:userIdOfReceiver 
  withGroupId:nil  //If launched for group, pass groupId(pass userId as nil)
  andwithDisplayName:nil //Not mendatory, if receiver is not already registered you should pass Displayname.
  andFromViewController:<YOUR CONTROLLER> ];
  
```

####Step 4: Push Notification Setup

#####a) Send device token to Applozic server :

In your AppDelegate’s **didRegisterForRemoteNotificationsWithDeviceToken **method send device registration to Applozic server after you get deviceToken from APNS. Sample code is as below:             

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


#####b) Receiving push notification :

Once your app receive notification, pass it to Applozic handler for chat notification processing.             

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
    } 
  }                                                           
```


#####c) Handling app launch on notification click :          

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

#####d) APNs Certification Type Setup :

Upload your push notification certificate to Applozic Dashboard page under 'Edit Application' section in order to enable real time notification.

In ALChatManager change setting according to your certificate and profile used:

Method Name:

```
-(void)ALDefaultChatViewSettings
```
Code to set mode depending on your code signing and profile used:

```
For Development:
    [ALUserDefaultsHandler setDeviceApnsType:(short)DEVELOPMENT];

For Distribution:
    [ALUserDefaultsHandler setDeviceApnsType:(short)DISTRIBUTION];
```


####Step 5: Logout User

Call the following when user logout from your app:

```
  ALRegisterUserClientService * alUserClientService = [[ALRegisterUserClientService alloc]init];
  if([ALUserDefaultsHandler getDeviceKeyString]){
      [alUserClientService logout];
  }
```

###Swift


####Download Chat SDK

**ADD APPLOZIC FRAMEWORK**

Download Applozic Chat latest framework [**here**](https://github.com/AppLozic/Applozic-iOS-SDK/raw/master/Frameworks) and add it to your project.

You can download Sample Chat app code (https://github.com/AppLozic/Applozic-iOS-SDK)  [**sample project**](https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sampleapp-swift) for more reference.


**Add framework to your project:**

i) Paste Applozic framework to root folder of your project. 

ii) Go to Build Phase. 

Expand Embedded frameworks and add applozic framework.         


![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-adding-applozic-framework.png)        


####Login/Register User
Applozic will create a new user if the user doesn't exists. userId is the unique identifier for any user, it can be anything like email, phone number or uuid from your database.


i) Add Helper Classes:

Download ALChatManager.swift and add to your project.

[**ALChatManager.swift**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp-swift/sampleapp-swift/ALChatManager.swift)  

ii) Add New cocoa class “NSObject+ApplozicBridge” in objective-c. On adding it will ask “would you like to create bridging header” say “yes” and in bridging file paste this code

```
#import "Applozic/ALMessage.h"
#import "Applozic/ALMessageClientService.h"
#import "Applozic/ALRegistrationResponse.h"
#import "Applozic/ALUser.h"
#import "Applozic/ALChatLauncher.h"
#import "Applozic/ALApplozicSettings.h"
#import "Applozic/ALAppLocalNotifications.h"
#import "Applozic/ALConversationService.h"

```

iii) Login/Register User:

Convenient methods are present in ALChatManager.swift to register user with applozic. For simple user registration in background, you can use below method:

```
  let alUser : ALUser =  ALUser();
  alUser.applicationId = ALChatManager.applicationId
  alUser.userId = "demoUserId"       // NOTE : +,*,? are not allowed chars in userId.
  alUser.emailId = "github@applozic.om"
  alUser.imageLink = ""    // User's profile image link.
  alUser.displayName = "DemoUserName"  // User's Display Name
  
  ALUserDefaultsHandler.setUserId(alUser.userId)
  ALUserDefaultsHandler.setEmailId(alUser.emailId)
  ALUserDefaultsHandler.setDisplayName(alUser.displayName)
```

```
 func registerUser(alUser: ALUser, completion : (response: ALRegistrationResponse, error: NSError?) -> Void)

```

####Initiate Chat

1 ) Launch chat list screen:

    NOTE: Replace "applozic-sample-app" by your application key 

```
    func registerUserAndLaunchChat(alUser:ALUser?, fromController:UIViewController,forUser:String?)
    
   //Example: 
   
        let chatManager : ALChatManager = ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.registerUserAndLaunchChat(getUserDetail(), fromController: self, forUser:nil)
```

2) Launch chat with specific user:

```
// Individual chat list launch for group or user with display name

 func launchChatForUser(forUserId : String ,fromViewController:UIViewController)

//Example:

        let chatManager : ALChatManager =  ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.registerUserAndLaunchChat(getUserDetail(), fromController: self, forUser:"applozic")
  
```

####Push Notification Setup

#####a) Send device token to Applozic server :

In your AppDelegate’s **didRegisterForRemoteNotificationsWithDeviceToken** method send device registration to Applozic server after you get deviceToken from APNS. Sample code is as below:             

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


#####b) Receiving push notification :

Once your app receive notification, pass it to Applozic handler for chat notification processing.             

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


#####c) Handling app launch on notification click :          

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

#####d) APNs Certification Type Setup :

Upload your push notification certificate to Applozic Dashboard page under 'Edit Application' section in order to enable real time notification.

In ALChatManager change setting according to your certificate and profile used:

Method Name:

```
ALDefaultChatViewSettings() -> Void
```
Code to set mode depending on your code signing and profile used:

```
For Development:
    ALUserDefaultsHandler.setDeviceApnsType(APNS_TYPE_DEVELOPMENT);

For Distribution:
    ALUserDefaultsHandler.setDeviceApnsType(APNS_TYPE_DISTRIBUTION);
```

####Logout User

Call the following when user logout from your app:

```
  let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
  registerUserClientService.logout();
```
