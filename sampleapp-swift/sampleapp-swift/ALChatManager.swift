//
//  ALChatManager.swift
//  applozicswift
//
//  Created by Devashish on 30/12/15.
//  Copyright © 2015 Applozic. All rights reserved.
//

import UIKit
import Applozic

class ALChatManager: NSObject {
    
    static let applicationId = "applozic-sample-app"
    
    
    // ----------------------
    
    // Call This at time of your app's user authentication OR User registration.
    // This will register your User at applozic server.
    
    
    //----------------------
    
    class func registerUser(alUser: ALUser) {
        
       
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: applicationId )
        alChatLauncher.ALDefaultChatViewSettings()

        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
            if (error != nil) {
                print("error while registering to applozic");
            } else {
                print("registered")
                
                if(isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken())){
                    alChatLauncher.registerForNotification()
                }
                
                //let messageClientService: ALMessageClientService = ALMessageClientService()
               // messageClientService.addWelcomeMessage()
                
            }
        })
        
    }
    
    // ----------------------  ------------------------------------------------------/
    
    // convenient method to launch chat-list, after user registration is done on applozic server.
    //
    // This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
    
    // ----------------------  ------------------------------------------------------/
    

    
    func launchChat(fromViewController:UIViewController){
        self.registerUserAndLaunchChat(nil, fromController: fromViewController, forUser: nil)
    }
    
    
    // ----------------------  ------------------------------------------------------/
    
    // convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
    //
    // This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
    
    // ----------------------  ------------------------------------------------------/
    
    func launchChatForUser(forUserId : String ,fromViewController:UIViewController){
        self.registerUserAndLaunchChat(nil, fromController: fromViewController, forUser: forUserId)
    }
    
    
    
    // ----------------------  ------------------------------------------------------/
    
    //      Method to register + lauch chats screen. If user is already registered, directly chats screen will be launched.
    //      If user information is not passed, it will try to get user information from getLoggedinUserInformation.
    //
    //
    //-----------------------  ------------------------------------------------------/
    
    
    func registerUserAndLaunchChat(alUser:ALUser?, fromController:UIViewController,forUser:String?)
    
    {
    
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: ALChatManager.applicationId)
       
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getDeviceKeyString())){
            if (ALChatManager.isNilOrEmpty(forUser)){
                let title  = ALChatManager.isNilOrEmpty(fromController.title) ?"< Back" : fromController.title;
                alChatLauncher.launchChatList(title, andViewControllerObject:fromController);
            }else {
                alChatLauncher.launchIndividualChat(forUser,andViewControllerObject: fromController,andWithText: nil)
            }
            return;
        }
        
        //register user as it is not registered already ...
        var user : ALUser;
        if ( alUser == nil) {
            user = ALChatManager.getUserDetail()
        }else {
            user = alUser!;

        }
        alChatLauncher.ALDefaultChatViewSettings();

        // register and launch...
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(user, withCompletion: { (response, error) in
            if (error != nil) {
                //TODO : show/handle error
                print("error while registering to applozic");
                return;
            } else if(response.message == "REGISTERD"){
                print("registered!!!")
                if(ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken())){
                    alChatLauncher.registerForNotification()
                }
                //let messageClientService: ALMessageClientService = ALMessageClientService()
                //messageClientService.addWelcomeMessage()
            }
            if (ALChatManager.isNilOrEmpty(forUser)){
                let title  = ALChatManager.isNilOrEmpty(fromController.title) ?"< Back" : fromController.title;
                alChatLauncher.launchChatList(title, andViewControllerObject:fromController);
            }else {
                alChatLauncher.launchIndividualChat(forUser,andViewControllerObject: fromController,andWithText: nil)
            }
        })
        
    }
    
    // ----------------------  ---------------------------------------------------------------------------------------------//
    
    //     This method can be used to get app logged-in user's information.
    //     if user information is stored in DB or preference, Code to get user's information should go here.
    //     This might be used to get existing user information in case of app update.
    
    //----------------------   -----------------------------------------------------------------------------------------//
    

    
    class func getUserDetail() -> ALUser {
        
        // TODO:Write your won code to get userId in case of update or in case of user is not registered....
        
        let user: ALUser = ALUser()
        user.userId = "iosdevtest"
        user.applicationId=ALChatManager.applicationId
        return user;
        
    }
  
    
    class func isNilOrEmpty(string: NSString?) -> Bool {
        
        switch string {
            
        case .Some(let nonNilString): return nonNilString.length == 0
            
        default:return true
            
        }
        
    }
}
