//
//  NewGameViewController.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 8/27/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit
import Firebase

class NewGameViewController: UITableViewController {
    
    let cellID = "cellID"
    var users = [User]()
    
    let maroonColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 100.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = maroonColor
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellID)
        
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {

                let user = User()

                user.name = dictionary["name"]
                user.email = dictionary["email"]
                user.id = snapshot.key
                self.users.append(user)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancelBlock: nil)
    }

    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startGame(toUserId: String, toUserName: String) {
        let playController : PlayViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlayView") as! PlayViewController
        playController.isMultiplayerGame = true
        playController.toUserId = toUserId
        playController.toUserName = toUserName
        self.presentViewController(playController, animated: false, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        let user = self.users[indexPath.row]
        if FIRAuth.auth()!.currentUser!.uid != user.id! {
        self.startGame(user.id!, toUserName: user.name!)
        }
        
        
    }
    
    

}

