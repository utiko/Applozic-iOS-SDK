### Notifications 

Enable/Disable Notification & Sound

Below method should be called to change notification.

```
//THIS IS OPTIONAL AND USE IF USER NEEDS TO UPDATE NOTIFICATIONS IN REAL TIME

short mode = 0  // SOUND + NOTIFICATION : THIS IS DEFAULT
short mode = 1  // NOTIFICATION WITHOUT SOUND
short mode = 2  // DISABLE NOTIFICATION : NO NOTIFICATION WILL COME FROM SERVER

[ALRegisterUserClientService updateNotificationMode:mode withCompletion:^(ALRegistrationResponse *response, NSError *error) { 
     [ALUserDefaultsHandler setNotificationMode:mode] ; 
      NSLog(@"UPDATE Notification Mode Response:%@ Error:%@",response,error); 
}];

```

### Contacts

Applozic framework provides convenient APIs for building your own contact. Developers can build and store contacts in three different ways. 

 **Build your contact:** 

** a) Simple method to create your contact is to create contact.
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


Below are additional APIs for contact load, update, delete and requires a ALContact object or array of ALContact objects. 

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
 

### Contextual Conversation
 
 Applozic SDK provide APIs which let you set and customise the chat's context. Developers can create a Conversation and launch a chat with context set. 

The picture below shown depicts the context header set below the navigation bar.Suppose a buyer want to have context chat with seller 'Adarsh' on product macbook pro.

 ![picture alt](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/images/contextBased.png "Context-based header view")

__ALConversationProxy__ is a class which let you build your conversation context

ALConversationProxy have three type of properties as following:          


   1. topicId : A unique ID for your Topic/context you want to chat.                        
   2. userId : User ID of receiver. 
   3. alTopicDetail: Contains the following:
   
      Topic title                                               
      Topic subtitle             
      Image link                
      key1 and value1: For ex. key1 be "Product ID" and value1 be "569-01"         
      key2 and value2: For ex. key1 be "Price" and value2 be "Rs.1,50,00"             



Key1 and Key2 is a placeholder to store with respective value1 and value2 values

#####Objective - C            

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

#####API to create conversation using ALConversationProxy object 

```
-(void)createConversation:(ALConversationProxy *)alConversationProxy withCompletion:(void(^)(NSError *error,ALConversationProxy * proxy ))completion;
```


### Channel/Group Messaging

This section explain about convenient SDK APIs  related to group.  

__Class to import :__ Applozic/ALChannelService.h 

##### Create Channel/Group

You can create a Channel/Group by simply calling createChannel method. The callback argument ALChannel will have Channel information created by applozic server.In case you are not passing clientChannelKey, you need to store channelKey from ALChannel object for any further operations( like : add member, remove  member, delete group/channel etc) on Channel/Group.   
```
-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData withCompletion:(void(^)(ALChannel *alChannel))completion
{
```

| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| channelName  | Yes  |   | channel name  |
| clientChannelKey  | No  | nil  | Channel key maintain by client. This can be any unique identifier passed by client, to identify his group/channel |
| memberArray  | Yes  |   | Array of group member's userId  |
| imageLink  | Yes  |   | group profile image link  |
| type  | Yes  |  PUBLIC=2 | type of the group. PRIVATE = 1,PUBLIC = 2, OPEN = 6 |
|metaData | optional | nil| Setting group meta data for messages like created group, left group, removed from group, group deleted, group icon changed and group name changed.|
| (void(^)(ALChannel *alChannel))completion  |   |   | completion block, once group is created successfully. This will return ALChannel object, which stores information about newly created channel. |

 
NOTE: Group metadata is optional and should be passed for custom group notification message only. Example method is below, how you can get custom message:

```
/**
 * :adminName - Admin display name of group
 * :userName -  user's display name
 * :groupName -  Group's Name
 *
 **/
-(NSMutableDictionary *)getChannelMetaData
{
    NSMutableDictionary *grpMetaData = [NSMutableDictionary new];

    [grpMetaData setObject:@":adminName created group" forKey:AL_CREATE_GROUP_MESSAGE];
    [grpMetaData setObject:@":userName removed" forKey:AL_REMOVE_MEMBER_MESSAGE];
    [grpMetaData setObject:@":userName added" forKey:AL_ADD_MEMBER_MESSAGE];
    [grpMetaData setObject:@":userName joined" forKey:AL_JOIN_MEMBER_MESSAGE];
    [grpMetaData setObject:@"Group renamed to :groupName" forKey:AL_GROUP_NAME_CHANGE_MESSAGE];
    [grpMetaData setObject:@":groupName icon changed" forKey:AL_GROUP_ICON_CHANGE_MESSAGE];
    [grpMetaData setObject:@":userName left" forKey:AL_GROUP_LEFT_MESSAGE];
    [grpMetaData setObject:@":groupName deleted" forKey:AL_DELETED_GROUP_MESSAGE];
    
    return grpMetaData;
}


```

 
##### Add User to Channel/Group
 ```
-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey 
orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error,ALAPIResponse *response))completion
 ``` 	 
 
| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| userId  | Yes  |   | member's userId to be added to group  |
| channelKey  | No |   | applozic channelKey. If clientChannelKey is passed, this should be passed as nil. |
| clientChannelKey  | No  |   | client channel identifier. This is mandatory if applozic channelKey is not passed. |
| (void(^)(NSError *error,ALAPIResponse *response))completion  | Yes  |   | completion block. If member added successfully, response object's status will have value as sucess. |


__NOTE:__ Only admin can add member to the group/channel. For more detail see check Admin section.


##### Remove user from Channel/Group
 ```
-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey 
orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error, NSString *response))completion
 ```
 
| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| userId  | Yes  |   | member's userId to be removed from group  |
| channelKey  | No |   | applozic channelKey. If clientChannelKey is passed, this should be passed as nil. |
| clientChannelKey  | No  |   | client channel identifier. This is mandatory if applozic channelKey is not passed. |
| (void(^)(NSError *error, NSString *response))completion  | Yes  |   | completion block. |



##### Delete Channel/Group
```
-(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion
```
 
| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| channelKey  | No |   | applozic channelKey. If clientChannelKey is passed, this should be passed as nil. |
| clientChannelKey  | No  |   | client channel identifier. This is mandatory if applozic channelKey is not passed. |
| (void(^)(NSError *error))completion  | Yes  |   | completion block. In case of sucess, error object will be nil |

__NOTE:__ Only admin can add member to the group/channel. For more detail see check Admin section.
 
##### Leave Channel/Group
```
-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey
     withCompletion:(void(^)(NSError *error))completion
```

| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| channelKey  | No |   | applozic channelKey. If clientChannelKey is passed, this should be passed as nil. |
| clientChannelKey  | No  |   | client channel identifier. This is mandatory if applozic channelKey is not passed. |
| (void(^)(NSError *error))completion  | Yes  |   | completion block. In case of sucess, error object will be nil |



##### Rename Channel/Group
 ```
-(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion
 ```

| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| channelKey  | No |   | applozic channelKey. If clientChannelKey is passed, this should be passed as nil. |
| newName  | Yes |   | new name of channel.|
| clientChannelKey  | No  |   | client channel identifier. This is mandatory if applozic channelKey is not passed. |
| (void(^)(NSError *error))completion  | Yes  |   | completion block. In case of sucess, error object will be nil |

If renamed successfully then it will return YES else NO. 


##### Group Admin

This method is to check whether the current user is channel/group admin or not.
As group admin have rights to do delete channel, remove  channel and add new member to channel. it is suggested to call this method to check admin rights before performing operations.
```
-(BOOL) checkAdmin:(NSNumber *) channelKey
```
| Parameter  | Required | Default | Description |
| ------------- | ------------- | ------------- | ------------- |       
| channelKey  | No |   | applozic channelKey.|

If renamed successfully then it will return YES else NO.                   


