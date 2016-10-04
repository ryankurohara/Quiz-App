//
//  LoginViewController.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 8/8/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var loginButton = FBSDKLoginButton()
    
    let maroonColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 100.0)
    
    @IBOutlet weak var aivLoadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 500, height: 70))
        navBar.translucent = false
        navBar.barTintColor = maroonColor
        self.view.addSubview(navBar);
        
        

        
        // Facebook Login
        loginButton.delegate = self
        self.loginButton.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.performSegueWithIdentifier("goToMenu", sender: self)
                
            } else {
                // No user is signed in.
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                self.view!.addSubview(self.loginButton)
                self.loginButton.hidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        NSLog("User logged in")
        self.loginButton.hidden = true
        aivLoadingSpinner.startAnimating()
        
        if (error != nil) {
            self.loginButton.hidden = false
            self.aivLoadingSpinner.stopAnimating()
        }
        else if result.isCancelled {
            self.loginButton.hidden = false
            self.aivLoadingSpinner.stopAnimating()
        }
        else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                
                NSLog("User logged in the Firebase")
                let rootRef = FIRDatabase.database().reference()
                rootRef.child("users").child(user!.uid).setValue(["email" : user!.email!, "name" : user!.displayName!])
                
                // Making additional fake users for now
                rootRef.child("users").child("12er341q25r123e51wgmh25").setValue(["email" : "jsmith@gmai.com", "name" : "John Smith"])
                rootRef.child("users").child("1234q16364dfwv355mgjmm6").setValue(["email" : "lol@gmail.com", "name" : "Tom Brady"])
                rootRef.child("users").child("563sdfnxvb45634sds56356").setValue(["email" : "asdf@gmail.com", "name" : "Jimmy Tatro"])
                
            }
        }
    
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User did log out")
    }

}
