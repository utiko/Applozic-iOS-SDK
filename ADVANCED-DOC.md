### Contacts             




Applozic framework provides convenient APIs for building your own contact. Developers can build and store contacts in three different ways. 

 **Build your contact:** 

** a ) Simple method to create your contact is to create contact.
**                 




** Objective - C **        
```
ALContact *contact1 = [[ALContact alloc] init];              
contact1.userId = @"adarshk"; // unique Id for user               
contact1.fullName = @"Adarsh Kumar"; // Fullname of the contact.               

//Display name for contact. This name would be displayed to the user in chat and contact list.                  
contact1.displayName = @"Adarsh";               
contact1.email = @"github@applozic.com"; //Email Id for the contact.              
//Contact image url. Contact image would be downloaded automatically from URL.                  
ontact1.contactImageUrl =@"https://www.applozic.com/resources/images/applozic_logo.gif";        
contact1.localImageResourceName = @"adarsh.jpg"; // If this field is mentioned,
Contact image will be taken from local storges.   
```


**b) Creating contact from dictionary:
**
You can directly create contact from dictionary, all you have to do is just pass a dictionary while initialising object.          




** Objective -C **  
```
  //Contact ------- Example with dictonary 
  NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init]; 
  [demodictionary setValue:@"adarshk" forKey:@"userId"]; 
  [demodictionary setValue:@"Adarsh Kumar" forKey:@"fullName"]; 
  [demodictionary setValue:@"Adarsh" forKey:@"displayName"];  
  [demodictionary setValue:@"github@applozic.com" forKey:@"email"]; 
  [demodictionary setValue:@"https://www.applozic.com/resources/images/applozic_logo.gif" forKey:@"contactImageUrl"]; 
  [demodictionary setValue:nil forKey:@"localImageResourceName"];              
  ALContact *contact5 = [[ALContact alloc] initWithDict:demodictionary];                   
```




**b) Building contact from JSON:
**           



** Objective -C **       
```
//Contact -------- Example with json                   
NSString *jsonString =@"{\"userId\": \"applozic\",\"fullName\": \"Applozic\",
\"contactNumber\": \"9535008745\",\"displayName\":  \"Applozic Support\",
\"contactImageUrl\": \"https://www.applozic.com/resources/images/applozic_logo.gif\",\"email\":       
\"devashish@applozic.com\",\"localImageResourceName\":\"sample.jpg\"}";                   
ALContact *contact4 = [[ALContact alloc] initWithJSONString:jsonString];                        
 ```
 
 
 
 **Add Your Contact:** 


**Add single contact API
**


** Objective - C **    

 ```
 -(BOOL)addContact:(ALContact *)contact;
 ```
 
 Example:
 ```
 ALContact *contact  = [[ALContact alloc] init];              
 contact.userId      = @"adarshk";      // Unique Id for user               
 contact.fullName    = @"Adarsh Kumar"; // Fullname of the contact.  
 contact.displayName = @"Adarsh";       // Name on display
 
 ALContactService * alContactService = [[ALContactService alloc] init];                   
 [alContactService addContact:contact]; 
```


Below are additional APIs for contact load, update and delete and requires a ALContact object or array of ALContact objects. 

** Objective - C **            
```

#  Fetch/Load contact API
/*  Use "userId" for <key> and contact's user id string as <value> for below API */
  - (ALContact *)loadContactByKey:(NSString *) key value:(NSString*) value
  
#   Update APIS                 
  -(BOOL)updateContact:(ALContact *)contact                    
  -(BOOL)updateListOfContacts:(NSArray *)contacts
 
#  Add contact(s) APIs              
  -(BOOL)addListOfContacts:(NSArray *)contacts          
  -(BOOL)addContact:(ALContact *)contact
 
#    Deleting APIS               
  //For purging single contact 
  -(BOOL)purgeContact:(ALContact *)contact             
  
  //For purging multiple contacts                
  -(BOOL)purgeListOfContacts:(NSArray *)contacts
  
  //For purging all contacts at once              
  -(BOOL)purgeAllContacts 
  
 ```
 

### **Contextual Conversation**
 
 Applozic SDK provide APIs which let you set and customise the chat’s context. Developers can create a ‘Conversation’ and launch a chat with context set. 

The picture below shown depicts the context header set below the navigation bar.Suppose a buyer want to have context chat with seller 'Adarsh' on product macbook pro.

 ![picture alt](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/images/contextBased.png "Context-based header view")

__ALConversationProxy__ is a class which let you build your conversation context

ALConversationProxy have three type of properties as following:          


   1.**topicId**: A unique ID for your Topic/context you want to chat.                        
   2.**userId**: User ID of person you like to start your chat with.                    
   3.**alTopicDetail**:
      Topic **title**                                               
      Topic **subtitle**             
      Image **link**                
      **key1**  and  **value1**: For ex. key1 be “Product ID” and value1 be “569-01”            
      **key2**  and  **value2**: For ex. key1 be “Price” and value2 be “Rs.1,50,00”              



**Key1 and Key2 is a placeholder to store with respective value1 and value2 values**

** Objective - C **            

```
ALConversationProxy * alConversationProxy = [[ALConversationProxy alloc] init];
alConversationProxy.topicId = @”buyMacPro";
alConversationProxy.userId = @"adarshk"
   
ALTopicDetail * alTopicDetail	= [[ALTopicDetail alloc] init];
alTopicDetail.title 		 	= @”Mac Book Pro";
alTopicDetail.subtitle 	  	= @"13’ Retina";
alTopicDetail.link = @"http://d.ibtimes.co.uk/en/full/319949/macbook-pro-13in-retina.jpg";
alTopicDetail.key1      	 	= @"Product ID";
alTopicDetail.value1    		= @"mac-pro-r-13";
alTopicDetail.key2      		= @"Price”;
alTopicDetail.value2    		= @"Rs.1,04,999.0";

NSData *jsonData = [NSJSONSerialization dataWithJSONObject:alTopicDetail.dictionary  
options:NSJSONWritingPrettyPrinted error:nil];
NSString *topicDetails = [[NSString alloc] initWithData:jsonData    encoding:NSUTF8StringEncoding];
 
alConversationProxy.topicDetailJson = topicDetails;
```

**       API to create conversation using ALConversationProxy object            **

```
-(void)createConversation:(ALConversationProxy *)alConversationProxy withCompletion:(void(^)(NSError *error,ALConversationProxy * proxy ))completion;
```



### UI Customization           




Applozic SDK provides various UI settings to customise chat view eaisly. If you are using __DemoChatManager.h__ explained in the  earlier section, you can put all your settings in below method. 

```
-(void)ALDefaultChatViewSettings;
```

If you have your own implementation, you should set UI Customization setting on successfull registration of user.

Below section will explain UI settings provided by Applozic SDK.


#### Received Message bubble color

__Objective-C__
```
[ALApplozicSettings setColorForReceiveMessages: [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]];
```

__Swift__
```
ALApplozicSettings.setColorForReceiveMessages(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1))
```

#### Send Message bubble color

__Objective-C__
```
[ALApplozicSettings setColorForSendMessages: [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
```

__Swift__
```
ALApplozicSettings.setColorForSendMessages(UIColor(red: 66.0/255, green: 173.0/255, blue: 247.0/255, alpha:1))
```

#### Set Colour for Navigation Bar

__Objective-C__
```
[ALApplozicSettings setColorForNavigation: [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
```

__Swift__
```
ALApplozicSettings.setColorForNavigation(UIColor(red: 66.0/255, green: 173.0/255, blue: 247.0/255, alpha:1))
```

#### Set Colour for Navigation Bar Item

__Objective-C__
```
[ALApplozicSettings setColorForNavigationItem: [UIColor whiteColor]];
```

__Swift__
```
ALApplozicSettings.setColorForNavigationItem(UIColor.whiteColor())
```

#### Hide/Show profile Image

__Objective-C__
```
[ALApplozicSettings setUserProfileHidden: NO];
```

__Swift__
```
ALApplozicSettings.setUserProfileHidden(false)
```

#### Hide/Show Tab Bar

__Objective-C__
```
[ALUserDefaultsHandler setBottomTabBarHidden: YES];
```

__Swift__
```
ALUserDefaultsHandler.setBottomTabBarHidden(false)
```

#### Hide/Show Logout Button (refresh button in sample app)

__Objective-C__
```
[ALUserDefaultsHandler setLogoutButtonHidden: YES];
```

__Swift__
```
ALUserDefaultsHandler.setLogoutButtonHidden(false)
```

#### Hide/Show Refresh Button

__Objective-C__
```
[ALApplozicSettings hideRefreshButton: NO];
```

__Swift__
```
ALApplozicSettings.hideRefreshButton(flag)
```

#### Set Title For Conversation Screen

__Objective-C__
```
[ALApplozicSettings setTitleForConversationScreen: @"Recent Chats"];
```

__Swift__
```
ALApplozicSettings.setTitleForConversationScreen("Recent Chats")
```

#### Set Font Face

__Objective-C__
```
[ALApplozicSettings setFontaFace: @"Helvetica"];
```

__Swift__
```
ALApplozicSettings.setFontFace("Helvetica")
```

#### Set Group Option

__Objective-C__
```
[ALApplozicSettings setGroupOption: YES];
```

__Swift__
```
ALApplozicSettings.setGroupOption(true)
```
This method is used when group feature is required . It will disable group functionality when set to NO.

#### Show/Hide Group Functions



##### Show/Hide Group Exit Button

__Objective-C__
```
[ALApplozicSettings setGroupExitOption:YES];
```

__Swift__
```
ALApplozicSettings.setGroupExitOption(true)
```


##### Show/Hide Group Member-Add Button (Admin only)

__Objective-C__
```
[ALApplozicSettings setGroupMemberAddOption:YES];
```

__Swift__
```
ALApplozicSettings.setGroupMemberAddOption(true)
```


##### Show/Hide Group Member-Remove Button (Admin only)

__Objective-C__
```
[ALApplozicSettings setGroupMemberRemoveOption:YES];
```

__Swift__
```
ALApplozicSettings.setGroupMemberRemoveOption(true)
```




### **Channel API** 

This section explain about convenient SDK APIs  related to group.  

__Class to import :__ Applozic/ALChannelService.h 

#### 1. Add new Channel

You can create a Channel/Group by simply calling createChannel method. The callback argument (channelKey) will be unique ChannelId/GroupId created by applozic server. You need to store this for any further operations( like : add member, remove  member, delete group/channel etc) on Channel/Group.  
```
-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink 
      withCompletion:(void(^)(ALChannel *alChannel))completion
```
__Parameters:__

__channelName :__ Name of group

__memberArray :__ Array of contactId/userid of members

 
#### 2. Add New member to Channel
 ```
-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey 
orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error,ALAPIResponse *response))completion
 ``` 	  	
__Parameters:__

__userId :__ contactId/userId

__channelkey :__ channel key/GroupId of your channel where member will be added.

If member added successfully then it will return YES else NO. 
 
__NOTE:__ Only admin can add member to the group/channel. For more detail see check Admin section.


#### 3.  Remove Member from Channel
 ```
-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey 
orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error, NSString *response))completion
 ```
__Parameters:__

__userId :__ contactId OR userId

__channelkey :__ channel key of your channel from which member will be removed.

If member removed successfully then it will return YES else NO. 

__NOTE:__ Only admin can add member to the group/channel. For more detail see check Admin section.
 

#### 4.   Delete Channel
```
-(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion
```
__Parameters:__

__channelkey :__ channel key of your channel from which member will be removed.

__Return Type :__ BOOL

If channel deleted successfully then it will return YES else NO. 

__NOTE:__ Only admin can add member to the group/channel. For more detail see check Admin section.
 

#### 5.   Leave Channel
```
-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey
     withCompletion:(void(^)(NSError *error))completion
```
__Parameters:__

__channelkey :__ channel key of your channel whom you are leaving.

__userId:__ userid  of leaving user

If member leaved successfully then it will return YES else NO. 


#### 6. Rename Channel
 ```
-(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion
 ```
__Parameters:__

__newName :__ new name of channel you wish to give

__channelkey :__ channel key of your channel whom you are renaming.

__Return Type :__ BOOL

If renamed successfully then it will return YES else NO. 


#### 7. Check Admin

This method is to check whether the current user is channel/group admin or not.
As group admin have rights to do delete channel, remove  channel and add new member to channel. it is suggested to call this method to check admin rights before performing operations.
```
-(BOOL) checkAdmin:(NSNumber *) channelKey
```
__Parameters:__

__channelkey :__ channel key of your channel

__Return Type :__ BOOL

If renamed successfully then it will return YES else NO.                   


