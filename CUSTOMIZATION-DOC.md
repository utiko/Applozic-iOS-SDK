

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
