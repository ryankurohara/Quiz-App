//
//  CurrentGamesViewController.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 8/27/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit
import Firebase

class CurrentGamesViewController: UITableViewController {
    
    let cellID = "cellIdCurrentGames"
    var games = [Game]()
    
    let maroonColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 100.0)


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = maroonColor
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(goHome))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Game", style: .Plain, target: self, action: #selector(handleNewGame))
        
        tableView.registerClass(GameCell.self, forCellReuseIdentifier: cellID)

        fetchGame()
    }
    
    func fetchGame() {
        FIRDatabase.database().reference().child("games").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {

                
                if let currentUser = FIRAuth.auth()?.currentUser {
                    if currentUser.uid == dictionary["userTwoId"] {
                        
                        let game = Game()
                        game.fromUserId  = dictionary["userOneId"]
                        game.fromUserName = dictionary["userOneName"]
                        game.scoreOne = Int(dictionary["userOneScore"]!)
                        game.turn = Int(dictionary["Turn"]!)
                        game.toUserName = dictionary["userTwoName"]
                        game.key = snapshot.key
                        if game.turn == 1 {
                            game.isItYourTurn = true
                        }
                        else {
                            game.isItYourTurn = false
                            game.scoreTwo = Int(dictionary["userTwoScore"]!)
                        }
                        self.games.append(game)
                    }
                }
                
                if let currentUser = FIRAuth.auth()?.currentUser {
                    if currentUser.uid == dictionary["userOneId"] {
                        
                        let game = Game()
                        game.fromUserId  = dictionary["userOneId"]
                        game.fromUserName = dictionary["userOneName"]
                        game.scoreOne = Int(dictionary["userOneScore"]!)
                        game.turn = Int(dictionary["Turn"]!)
                        game.toUserName = dictionary["userTwoName"]
                        game.key = snapshot.key
                        game.isItYourTurn = false
                        if game.turn == 2 {
                            game.scoreTwo = Int(dictionary["userTwoScore"]!)
                        }
                        self.games.append(game)
                    }
                }
                

                
      
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
            
        }, withCancelBlock: nil)
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func goHome() {
        let homeController : UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("navControllerStoryBoard") as! UINavigationController
        self.presentViewController(homeController, animated: false, completion: nil)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        
        let game = games[indexPath.row]
        
        if game.isItYourTurn! && game.turn == 1 {
            cell.textLabel?.text = game.fromUserName
            cell.detailTextLabel?.text = "Opponent's Score: " + String(game.scoreOne!) + ", It's your turn!"
        }
        else if !game.isItYourTurn! && game.turn == 1 {
            cell.textLabel?.text = game.toUserName
            cell.detailTextLabel?.text = "Your Score: " + String(game.scoreOne!) + ", It's their turn!"
        }
        else {
            cell.textLabel?.text = "Game Finished"
            let phrase1 = game.fromUserName! + "'s Score: " + String(game.scoreOne!)
            let phrase2 = game.toUserName! + "'s Score: " + String(game.scoreTwo!)
            cell.detailTextLabel?.text = phrase1 + ", " + phrase2
        }
        
 
        
        return cell
    }
    
    func handleNewGame() {
        let newMessageController = NewGameViewController()
        let navController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        let game = self.games[indexPath.row]
        if game.isItYourTurn! {
            self.startGame(game.key!)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {
            let refScores = FIRDatabase.database().reference().child("games")
            let childRef = refScores.child(games[indexPath.row].key!)
            childRef.removeValue()
            games.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            
        }
    }

    func startGame(gameKey: String) {
        let playController : PlayViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlayView") as! PlayViewController
        playController.isMultiplayerGame = true
        playController.isTurnTwo = true
        playController.gameKey = gameKey
        self.presentViewController(playController, animated: false, completion: nil)
    }

    
    
    
}
