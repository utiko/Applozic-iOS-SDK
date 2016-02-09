//
//  LaunchChatFromSimpleVCViewController.swift
//  sampleapp-swift
//
//  Created by Devashish on 09/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

import UIKit
import Applozic


class LaunchChatFromSimpleVCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func launchList(sender: AnyObject) {
        
        let chatManager : ALChatManager =  ALChatManager()
        chatManager.registerUserAndLaunchChat(getUserDetail(), fromController: self, forUser:nil)
    }
    
    
    
    
    
    @IBAction func launchUserChat(sender: AnyObject) {
        let chatManager : ALChatManager =  ALChatManager()
        
        chatManager.registerUserAndLaunchChat(getUserDetail(), fromController: self, forUser:"applozic")
    
    }
    
    
    
    @IBAction func logout(sender: AnyObject) {
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        
      registerUserClientService.logout();
      self.dismissViewControllerAnimated(false, completion: nil)
        
    
    }
    
    func getUserDetail() -> ALUser {
        
        // TODO:Write your won code to get userId in case of update or in case of user is not registered....
        
        let user: ALUser = ALUser()
        user.userId = ALUserDefaultsHandler.getUserId();
        user.applicationId=ALChatManager.applicationId;
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getEmailId())){
            user.emailId = ALUserDefaultsHandler.getEmailId();
        }
        return user;
}
    
    
    
   }
