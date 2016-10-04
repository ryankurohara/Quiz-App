//
//  ProfileViewController.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 8/25/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FBSDKCoreKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var numQuestions: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()


        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        self.profilePicture.clipsToBounds = true
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            let name = user.displayName
            self.username.text = name
            
            // Setup Statistics
            let numCorrect = NSUserDefaults.standardUserDefaults().integerForKey("numCorrect")
            let numAnswerred = NSUserDefaults.standardUserDefaults().integerForKey("numAnswered")
            
            let accuracy = Double(numCorrect)/Double(numAnswerred)
            self.accuracy.text = "Accuracy: " + String(Double(round(1000*accuracy)/1000))
            self.numQuestions.text = "Number of Questions Answered: " + String(numAnswerred)
            
            // reference to storage service
            let storage = FIRStorage.storage()
            
            // refer your particular storage service
            let storageRef = storage.referenceForURL("gs://quizapp-fa053.appspot.com")
            
            let profilePicRef = storageRef.child(user.uid+"/profile_pic.jpg")

            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    NSLog("unable to download image")
                } else {
                    if data != nil {
                        self.profilePicture.image = UIImage(data:data!)
                    }
                }
            }
            
            if self.profilePicture.image == nil {
                let profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300,"width":300,"redirect":false], HTTPMethod: "Get")
                profilePic.startWithCompletionHandler({(connection,result,error) -> Void in
                    if(error == nil) {
                        
                        let dictionary = result as? NSDictionary
                        let data = dictionary?.objectForKey("data")
                        
                        let urlPic = (data?.objectForKey("url"))! as! String
                        
                        if let imageData = NSData(contentsOfURL: NSURL(string:urlPic)!) {
                            
                            _ = profilePicRef.putData(imageData, metadata:nil) {
                                metadata,error in
                                
                                if error == nil {
                                    _ = metadata!.downloadURL
                                }
                                else {
                                    NSLog("Error downloading image")
                                }
                                
                            }
                            self.profilePicture.image = UIImage(data:imageData)
                        }

                        
                    }

                    
                })
            }
            
            
            
        } else {
            // No user is signed in.
        }
        
        
    }

    @IBAction func resetStats(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "numAnswered")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "numCorrect")
        self.accuracy.text = "Accuracy: 0.0"
        self.numQuestions.text = "Number of Questions Answered: 0"
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
