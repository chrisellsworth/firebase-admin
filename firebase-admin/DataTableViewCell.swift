//
//  DataTableViewCell.swift
//  firebase-admin
//
//  Created by Chris Ellsworth on 12/3/15.
//  Copyright © 2015 Chris Ellsworth. All rights reserved.
//

import UIKit
import Firebase

class DataTableViewCell : UITableViewCell {
    var ref: Firebase?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}