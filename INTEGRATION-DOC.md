####Step 1: Download Chat SDK

**ADD APPLOZIC FRAMEWORK**

Download Applozic Chat latest framework [**here**](https://github.com/AppLozic/Applozic-iOS-SDK/raw/master/Frameworks) and add it to your project.

You can download Sample Chat app code (https://github.com/AppLozic/Applozic-iOS-SDK)  [**sample project**](https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sampleapp) for more reference.


**Add framework to your project:**

i ) Paste Applozic framework to root folder of your project. 

ii ) Go to Build Phase. 

Expand  Embedded frameworks and add applozic framework.         


![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-adding-applozic-framework.png)        


####Step 2:  Login/Register User
Applozic will create a new user if the user doesn't exists. userId is the unique identifier for any user, it can be anything like email, phone number or uuid from your database.


i) Add Helper Classes:

Download ALChatManager.h and ALChatManager.m file and add to your project.

[**ALChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/ALChatManager.h)        

[**ALChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/ALChatManager.m)  

Change applicationID in ALChatManager.h, fill your logged-in user detail and you are ready to launch your chat from your controller.


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
If you want to do something just after user registartion you can use below method. For example, if your very first screen of app is chat screen, you can launch chatlist on success of registration. 

```
-(void)registerUserWithCompletion:(ALUser *)alUser withHandler:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion
```


####Step 3: Initiate Chat

1 ) Launch chat list screen:

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

**a ) Send device token to Applozic server:**

In your AppDelegate’s **didRegisterForRemoteNotificationsWithDeviceToken **method send device registration to Applozic server after you get deviceToken from APNS. Sample code is as below:             


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

Once your app receive notification, pass it to Applozic handler for chat notification processing.             


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

**d) APNs Certification Type Setup :**

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
