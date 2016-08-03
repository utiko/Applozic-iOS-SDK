
####Create your Application

a ) Once you signed up create your Application with required details on admin dashboard. Upload your push-notification certificate to our portal to enable real time notification.         




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Dashboard.png)         


b) Once you create your application you can see your application key listed on admin dashboard. Please use same application key explained in further steps.          




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-dashboard-content-page.png)         





####Installing the iOS SDK


**ADD APPLOZIC FRAMEWORK**

Download our latest framework [**here**](https://github.com/AppLozic/Applozic-iOS-SDK/raw/master/Frameworks) and add it to your project.

You can clone or download our (https://github.com/AppLozic/Applozic-iOS-SDK)  [**sample project**](https://github.com/AppLozic/Applozic-iOS-SDK/raw/master/Frameworks/Universal%20Release%202.9/Applozic.framework.zip) for more reference.


**Add framework to your project:**

i ) Paste Applozic framework to root folder of your project. 
ii ) Go to Build Phase. Expand  Embedded frameworks and add applozic framework.         




![dashboard-blank-content](https://raw.githubusercontent.com/AppLozic/Applozic-Chat-SDK-Documentation/master/Resized-adding-applozic-framework.png)        


####Quickly Launch your chat


You can test your chat quickly by adding below .h and .m file to your project.

[**DemoChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/DemoChatManager.h)        

[**DemoChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sampleapp/applozicdemo/DemoChatManager.m)  

Change applicationID in DemoChatManager, fill your logged-in user deatil and you are ready to launch your chat from your controller :)

Launch your chat

```
//Replace with your application key in DemoChatManager.h

#define APPLICATION_ID @"applozic-sample-app" 

//Add your logged in user detail in getLoggedinUserInformation method in DemoChatManager.

+( ALUser * )getLoggedinUserInformation
{
    ALUser *user = [[ALUser alloc] init];
    [user setApplicationId:APPLICATION_ID];
    [user setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];      // 3. APP_MODULE_NAME setter
    
    // Write your logic to get user information here. May be from user preference.
    //[user setUserId:<YOUR LOGGED IN USER ID>];
    
    //NOT Mandatory 
    //[user setEmailId:<EMIAL ID>];
    //[user setPassword:<USER_PASSWORD>];
    
    return user;
}

//Launch your Chat from your controller.
 DemoChatManager * demoChatManager = [[DemoChatManager alloc]init];
    [demoChatManager launchChat:<yourcontrollerReference> ];

```

####** Detail about user creation and registration: **

i ) create user :
  To create user you need to create object of ALUser.
  
```
  ALUser *user = [[ALUser alloc] init];
  [user setUserId:@"testUser"]; //NOTE : +,*,? are not allowed chars in userId.
  [user setDisplayName:@"Applozic Test"]; // Display name of user 
  [user setContactNumber:@""];// formatted contact no
  [user setimageLink:@"user_profile_image_link"];// User's profile image link.
  
```

ii ) Registration of user: Once you create user, you can register user with applozic server. Convenient methods are present in DemoChatmanager.m to register user with applozic. For simple user registration in background, you can use below method:

```
 -(void)registerUser:(ALUser *)alUser;

```
If you want to do something just after user registartion you can use below method. For example, if your very first screen of app is chat screen, you can launch chatlist on success of registartion. 

```
-(void)registerUserWithCompletion:(ALUser *)alUser withHandler:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion

```
####**Launching Chats :**

1 ) chat list launch:

```
-(void)launchChat: (UIViewController *)fromViewController; //Use this method to launch chat list
   
   //Example: 
    DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
    [demoChatManager launchChat:<Your Controller>];
```

2) individual user's chat launch:

```
// Individual chat list launch for group or user with disaplayname

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController;

//Example:
  NSString * userIdOfReceiver =  @"receiverUserId";
  DemoChatManager * demoChatManager = [[DemoChatManager alloc] init];
  [demoChatManager launchChatForUserWithDisplayName:userIdOfReceiver 
  withGroupId:nil  //If launched for group, pass groupId(pass userId as nil)
  andwithDisplayName:nil //Not mendatory, if receiver is not already registered you should pass Displayname.
  andFromViewController:<YOUR CONTROLLER> ];
  
```

####PUSH NOTIFICATION REGISTRATION AND HANDLING

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

**c) APNs Certification Type Setup :**

In DemoChatManager change setting according to your certificate and profile used:

Method Name:

```
-(void)ALDefaultChatViewSettings
```
code to set mode depending on your code signing and profile used:

```
For Development:
    [ALUserDefaultsHandler setDeviceApnsType:(short)DEVELOPMENT];

For Distribution:
    [ALUserDefaultsHandler setDeviceApnsType:(short)DISTRIBUTION];
```
