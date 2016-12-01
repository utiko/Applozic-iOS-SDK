

Applozic SDK provides various UI settings to customise chat view easily. If you are using __ALChatManager.h__ explained in the  earlier section, you can put all your settings in below method. 

```
-(void)ALDefaultChatViewSettings;
```

If you have your own implementation, you should set UI Customization setting on successfull registration of user.

Below section explains UI settings provided by Applozic SDK.

#### Chat Bubble

##### Received Message bubble color

__Objective-C__
```
[ALApplozicSettings setColorForReceiveMessages: [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]];
```

__Swift__
```
ALApplozicSettings.setColorForReceiveMessages(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1))
```

##### Send Message bubble color

__Objective-C__
```
[ALApplozicSettings setColorForSendMessages: [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
```

__Swift__
```
ALApplozicSettings.setColorForSendMessages(UIColor(red: 66.0/255, green: 173.0/255, blue: 247.0/255, alpha:1))
```

#### Chat Background

__Objective-C__
```
[ALApplozicSettings setChatWallpaperImageName:@"<WALLPAPER NAME>"];
```

__Swift__
```
ALApplozicSettings.setChatWallpaperImageName("<WALLPAPER NAME>")
```

### Chat Screen

Hide/Show profile Image

__Objective-C__
```
[ALApplozicSettings setUserProfileHidden: NO];
```

__Swift__
```
ALApplozicSettings.setUserProfileHidden(false)
```

Hide/Show Refresh Button

__Objective-C__
```
[ALApplozicSettings hideRefreshButton: NO];
```

__Swift__
```
ALApplozicSettings.hideRefreshButton(flag)
```

Chat Title

__Objective-C__
```
[ALApplozicSettings setTitleForConversationScreen: @"Recent Chats"];
```

__Swift__
```
ALApplozicSettings.setTitleForConversationScreen("Recent Chats")
```


#### Group Messaging

__Objective-C__
```
[ALApplozicSettings setGroupOption: YES];
```

__Swift__
```
ALApplozicSettings.setGroupOption(true)
```
This method is used when group feature is required . It will disable group functionality when set to NO.



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

##### Disable GroupInfo (Tap on group Title)

__Objective-C__
```
[ALApplozicSettings setGroupInfoDisabled:YES];
```

__Swift__
```
ALApplozicSettings.setGroupInfoDisabled(true)
```

##### Disable GroupInfoEdit (Edit group name and image)

__Objective-C__
```
[ALApplozicSettings setGroupInfoEditDisabled:YES];
```

__Swift__
```
 ALApplozicSettings.setGroupInfoEditDisabled(true)
 ```

#### Theme Customization

##### Set Colour for Navigation Bar

__Objective-C__
```
[ALApplozicSettings setColorForNavigation: [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
```

__Swift__
```
ALApplozicSettings.setColorForNavigation(UIColor(red: 66.0/255, green: 173.0/255, blue: 247.0/255, alpha:1))
```

##### Set Colour for Navigation Bar Item

__Objective-C__
```
[ALApplozicSettings setColorForNavigationItem: [UIColor whiteColor]];
```

__Swift__
```
ALApplozicSettings.setColorForNavigationItem(UIColor.whiteColor())
```


##### Hide/Show Tab Bar

__Objective-C__
```
[ALUserDefaultsHandler setBottomTabBarHidden: YES];
```

__Swift__
```
ALUserDefaultsHandler.setBottomTabBarHidden(true)
```

##### Set Font Face

__Objective-C__
```
[ALApplozicSettings setFontaFace: @"Helvetica"];
```

__Swift__
```
ALApplozicSettings.setFontFace("Helvetica")
```


#### UI source code

For complete control over UI, you can also download open source chat UI toolkit and change it as per your designs :

[https://github.com/AppLozic/Applozic-iOS-SDK](https://github.com/AppLozic/Applozic-iOS-SDK)


Import [Applozic iOS Library](https://github.com/AppLozic/Applozic-iOS-SDK/tree/master/sample-with-framework/Applozic) into your Xcode project.

Applozic contains the UI related source code, icons, views and other resources which you can customize based on your design needs.

Sample app with integration is available under [**sampleapp**](https://github.com/AppLozic/Applozic-iOS-Chat-Samples)
