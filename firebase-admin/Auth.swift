//
//  Auth.swift
//  firebase-admin
//
//  Created by Chris Ellsworth on 11/28/15.
//  Copyright © 2015 Chris Ellsworth. All rights reserved.
//

import Foundation

class Auth: CustomStringConvertible {
    var data: [String: AnyObject]
    
    init(data: [String:AnyObject]) {
        self.data = data
    }
    
    lazy var email: String = {
        return self.data["user"]!["email"]! as! String
    }()
    
    lazy var token: String = {
        return self.data["session"]!["token"]! as! String
    }()
    
    lazy var expires: NSDate = {
        let timeInterval = self.data["session"]!["expires"]! as! NSNumber
        return NSDate(timeIntervalSince1970: timeInterval.doubleValue / 1000)
    }()
    
    func expired() -> Bool {
        return self.expires.timeIntervalSinceNow < 0
    }
    
    var description: String {
        return "\(email); expires \(expires)"
    }
}