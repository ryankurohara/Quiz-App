//
//  UserCell.swift
//  QuizApp
//
//  Created by Ryan K Kurohara on 8/27/16.
//  Copyright © 2016 ryankurohara. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
