//
//  MenuViewController.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 7/22/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class MenuViewController: UIViewController {
    
    let maroonColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 100.0)

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBAction func challengeButton(sender: AnyObject) {
        let newCurrentGamesController = CurrentGamesViewController()
        let navController = UINavigationController(rootViewController: newCurrentGamesController)
        presentViewController(navController, animated: true, completion: nil)

    }
    
    @IBAction func signOut(sender: AnyObject) {
        
        // Log out of Firebase
        try! FIRAuth.auth()!.signOut()

        // Log out of Facebook
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let loginController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
        self.presentViewController(loginController, animated: true, completion: nil)

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            welcomeLabel.text = "Welcome back, " + user.displayName!
        } else {
            // No user is signed in.
        }
        
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = maroonColor
        self.title = "QUIZINATOR"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BIG JOHN", size: 20)!,
                                                                    NSForegroundColorAttributeName: UIColor.whiteColor()]

    }

    @IBAction func rateButton(sender: AnyObject) {
        //UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id{PUT APP ID HERE}")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
