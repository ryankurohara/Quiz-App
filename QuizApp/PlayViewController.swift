//
//  PlayViewController.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 7/22/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit
import Firebase

struct Question {
    var Word : String!
    var Hint : String!
}

class PlayViewController: UIViewController, UINavigationBarDelegate {
    
    var isMultiplayerGame = Bool?(false)
    var toUserId = String?("")
    var toUserName = String?("")
    var gameKey = String?("")
    var isTurnTwo = Bool?(false)
    var isGamePlaying = true
    
    // Setup timer
    var timerSeconds = NSTimer()
    var timerMain = NSTimer()
    var counter = 30
    var score = 0
    
    let maroonColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 100.0)
    
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet var Answers: [UIButton]!
    @IBOutlet weak var results: UILabel!
    @IBOutlet weak var nextQuestionLabel: UIButton!
    @IBOutlet weak var countingLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    var currentAnswer = String()
    var isAnswerChosen = Bool()
    var nounDictionary = [String: String]()
    var verbDictionary = [String: String]()
    var adjDictionary = [String: String]()
    
    let numAnswers = 4
    
    let darkGreen = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 100.0)
    let lightGreen = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 100.0)
    let darkBlue = UIColor(red: 41.0/255.0, green: 128.0/255.0, blue: 185.0/255.0, alpha: 100.0)
    let lightBlue = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 100.0)
    let darkPurple = UIColor(red: 142.0/255.0, green: 68.0/255.0, blue: 173.0/255.0, alpha: 100.0)
    let lightPurple = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 100.0)
    let darkGray = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 100.0)
    let lightGray = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 100.0)
    
    // This is the root reference to the Firebase Database
    var rootRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        // Read the "SATwordlist" file into three dictionaries
        if let filepath = NSBundle.mainBundle().pathForResource("SATwordlist", ofType: "rtf") {
            
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil)
                
                contents.enumerateLinesUsingBlock({ (line, stop) -> () in
                    let myStringArr = line.componentsSeparatedByString(" ")

                    let size = myStringArr.count
                    var word = ""
                    var pos = ""
                    var definition = ""
                    
                    for i in 0..<size {
                        if myStringArr[i].rangeOfString("\\") == nil {
                            word = myStringArr[i]
                            if i+1 < size {
                                pos = myStringArr[i+1]
                            }
                            definition = line.componentsSeparatedByString(word + " " + pos + " ").last!
                            definition = definition.componentsSeparatedByString(".").first!
                            definition = definition.componentsSeparatedByString("\\").first!
                            break
                        }
                    }
                    
                    switch pos {
                    case "n.":
                        self.nounDictionary[word] = definition
                    case "v.":
                        self.verbDictionary[word] = definition
                    case "adj.":
                        self.adjDictionary[word] = definition
                    default: break
                    }
                })
            }
            catch {
                // Do nothing.
            }
        }
        
        createQuestion()
        
        // RUN THIS METHOD IF THE USER IS PLAYING ANOTHER USER IN CHALLENGE MODE
        if isMultiplayerGame! {
        
            let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70))
            
            navBar.translucent = false
            navBar.barTintColor = maroonColor
            navBar.tintColor = UIColor.whiteColor()
            navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            navBar.delegate = self
            
            let navigationItem = UINavigationItem()
            navigationItem.title = "It's your turn!"
            let leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
            navigationItem.leftBarButtonItem = leftButton

            navBar.items = [navigationItem]
            
            countingLabel.text = String(counter)
            scoreLabel.text = "Score: " + String(score)
            timerSeconds = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            timerSeconds = NSTimer.scheduledTimerWithTimeInterval(30, target:self, selector: #selector(timesUp), userInfo: nil, repeats: false)

    
            self.view.addSubview(navBar);

        }
        // *******************************************************************
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateCounter() {
        counter -= 1
        countingLabel.text = String(counter)
    }
    
    func timesUp() {
        if isGamePlaying {
            if !isTurnTwo! { // Execute this code if it is turn one
                
                let refScores = FIRDatabase.database().reference().child("games")
                let childRef = refScores.childByAutoId()
                let fromUserId = FIRAuth.auth()!.currentUser!.uid
                let fromUserName = FIRAuth.auth()!.currentUser!.displayName
                let values = ["userOneScore": String(score),
                              "userTwoId": toUserId!,
                              "userTwoName": toUserName!,
                              "userOneId": fromUserId,
                              "userOneName": fromUserName!,
                              "Turn" : "1"]
                childRef.updateChildValues(values as [NSObject : AnyObject])
                
                // Open new view up
                
                
            }
            else { // Execute this code if it is turn two
                let refScores = FIRDatabase.database().reference().child("games")
                let childRef = refScores.child(gameKey!)
                let values = ["userTwoScore": String(score),
                              "Turn" : "2"]
                childRef.updateChildValues(values as [NSObject : AnyObject])
            
            }
            
            let newCurrentGamesController = CurrentGamesViewController()
            let navController = UINavigationController(rootViewController: newCurrentGamesController)
            presentViewController(navController, animated: true, completion: nil)
        }

    }
    

    func createQuestion() {

        // Selects a random word from the given list and chooses three more random answer choices
        
        var dictionary = [String: String]()
        let randomNumber = Int(arc4random_uniform(3)) // Magic Number 3 for three parts of speech (noun, verb, adjective)
        switch randomNumber {
        case 0:
            dictionary = nounDictionary
        case 1:
            dictionary = verbDictionary
        case 2:
            dictionary = adjDictionary
        default: break
        }

        // asdf
        
        var allAnswers = [String]()
        var randNumArray = [Int]()
        let getRandom = self.randomSequenceGenerator(0, max: Int(dictionary.keys.count)-1)
        for _ in 0..<self.numAnswers {
            randNumArray.append(getRandom())
        }
        var sortedNumbers = randNumArray.sort(self.sortFunc)
        var count = 0
        
        let randomNum = Int(arc4random_uniform(UInt32(self.numAnswers)))
        for key in dictionary.keys {
            if count == sortedNumbers[0] {
                if allAnswers.count == randomNum {
                    self.QuestionLabel.text = dictionary[key]
                    self.currentAnswer = key
                }
                allAnswers.append(key)
                sortedNumbers.removeAtIndex(0)
            }
            if allAnswers.count == self.numAnswers {
                break
            }
            count += 1
        }
        
        var count2 = 0
        for answer in allAnswers {
            self.Answers[count2].setTitle(answer, forState: UIControlState.Normal)
            count2 += 1
        }
        

        results.backgroundColor = UIColor.whiteColor()
        results.textColor = UIColor.whiteColor()
        nextQuestionLabel.hidden = true
        isAnswerChosen = false
        
        // ******** Setup Button Colors ********************************
        var darkColor: UIColor?
        let randNumber2 = Int(arc4random_uniform(4)) // Magic number 4 for four colors
        switch randNumber2 {
        case 0: darkColor = darkGreen
        case 1: darkColor = darkBlue
        case 2: darkColor = darkPurple
        case 3: darkColor = darkGray
        default: break
        }
        QuestionLabel.backgroundColor = darkColor
        for i in 0..<Answers.count {
            Answers[i].backgroundColor = darkColor
        }
        
        
    }
    
    @IBAction func AnswerChosen(sender: UIButton) {
        if !isAnswerChosen {
            isAnswerChosen = true
            nextQuestionLabel.hidden = false
            if sender.currentTitle! == currentAnswer {
                // Answer is correct
                results.text = "Correct!"
                results.backgroundColor = darkGreen
                NSUserDefaults.standardUserDefaults().setInteger(NSUserDefaults.standardUserDefaults().integerForKey("numAnswered") + 1, forKey: "numAnswered")
                NSUserDefaults.standardUserDefaults().setInteger(NSUserDefaults.standardUserDefaults().integerForKey("numCorrect") + 1, forKey: "numCorrect")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                
                if isMultiplayerGame! {
                    score += 1
                    scoreLabel.text = "Score: " + String(score)
                }
            }
            else {
                // Answer is incorrect
                results.text = "Incorrect!"
                results.backgroundColor = UIColor.redColor()
                NSUserDefaults.standardUserDefaults().setInteger(NSUserDefaults.standardUserDefaults().integerForKey("numAnswered") + 1, forKey: "numAnswered")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                
                if isMultiplayerGame! {
                    score -= 1
                    scoreLabel.text = "Score: " + String(score)
                }
            }
        }
    }
    
    @IBAction func nextQuestionButton(sender: AnyObject) {
        createQuestion()
    }
    
    func randomSequenceGenerator(min: Int, max: Int) -> () -> Int {
        var numbers: [Int] = []
        return {
            if numbers.count == 0 {
                numbers = Array(min ... max)
            }
            
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            return numbers.removeAtIndex(index)
        }
    }
    
    func sortFunc(num1: Int, num2: Int) -> Bool {
        return num1 < num2
    }
    
    func handleCancel() {
        isGamePlaying = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
}
