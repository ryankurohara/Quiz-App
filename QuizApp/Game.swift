//
//  Game.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 8/31/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit

class Game: NSObject {
    var key : String?
    var scoreOne : Int?
    var scoreTwo: Int?
    var toUser : String?
    var toUserName : String?
    var fromUserId : String?
    var fromUserName : String?
    var turn : Int? // 1 is first turn and 2 is second turn
    var isItYourTurn : Bool?
}

