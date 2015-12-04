//
//  FirebaseAPI.swift
//  firebase-admin
//
//  Created by Chris Ellsworth on 11/22/15.
//  Copyright © 2015 Chris Ellsworth. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPI {
    
    lazy var auth: Auth? = {
        if self.authData != nil {
            return Auth(data: self.authData!)
        } else {
            return nil
        }
    }()
    
    var authData: [String:AnyObject]? {
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "auth")
        }
        get {
            return NSUserDefaults.standardUserDefaults().dictionaryForKey("auth")
        }
    }

    var dataTokens = [String: String]()

    func validToken() -> Bool {
        return self.auth != nil ? !self.auth!.expired() : false
    }

    func login(callback: (String?, NSError?) -> Void) {
        if (validToken()) {
            print("already authed \(auth!)")
            callback(self.auth?.token, nil)
        } else {
            let ticket = NSUUID().UUIDString

            let ticketsRef = Firebase(url: "https://firebase.firebaseio.com").childByAppendingPath("sessionTickets")

            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "www.firebase.com"
            components.path = "/login/confirm.html"

            components.queryItems = [
                    NSURLQueryItem(name: "ticket", value: ticket)
            ]

            NSOperationQueue.mainQueue().addOperationWithBlock({
                UIApplication.sharedApplication().openURL(components.URL!)
            })

            let value = ["created": FirebaseServerValue.timestamp()]

            let ticketRef = ticketsRef.childByAppendingPath(ticket)

            ticketRef.setValue(value) {
                (error, ref) -> Void in

                if (error != nil) {
                    callback(nil, error);
                } else {
                    ticketRef.childByAppendingPath("result").observeEventType(FEventType.Value, withBlock: {
                        (snapshot) -> Void in
                        if let value = snapshot.value as? [String:AnyObject] {
                            self.authData = value
                            print("authed as \(self.authData)")
                            callback(self.auth?.token, nil);
                        }
                    }, withCancelBlock: {
                        (error) -> Void in
                        callback(nil, error)
                    })
                }
            }
        }
    }

    func account(callback: ([String:AnyObject]?, NSError?) -> Void) {
        if (self.auth?.token != nil) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)

            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "admin.firebase.com"
            components.path = "/account"

            components.queryItems = [
                    NSURLQueryItem(name: "token", value: self.auth?.token)
            ]

            let request = NSMutableURLRequest(URL: components.URL!)
            let task = session.dataTaskWithRequest(request) {
                (data, response, error) -> Void in
                if (error != nil) {
                    callback(nil, error)
                } else {
                    let result = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
                    callback(result, nil)
                }
            }
            task.resume()
        } else {
            login({(auth, error) -> Void in
                self.account(callback)
            })
        }
    }

    func token(firebase: String, callback: ([String:AnyObject]?, NSError?) -> Void) {
        if (self.auth?.token != nil) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)

            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "admin.firebase.com"
            components.path = "/firebase/\(firebase)/token"

            components.queryItems = [
                    NSURLQueryItem(name: "token", value: self.auth?.token),
                    NSURLQueryItem(name: "auth", value: "true")
            ]

            let request = NSMutableURLRequest(URL: components.URL!)
            let task = session.dataTaskWithRequest(request) {
                (data, response, error) -> Void in
                if (error != nil) {
                    callback(nil, error)
                } else {
                    let result = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]

                    let dataToken = result["personalToken"] as! String?
                    self.dataTokens[firebase] = dataToken

                    callback(result, nil)
                }
            }
            task.resume()
        } else {
            login({(auth, error) -> Void in
                self.account(callback)
            })
        }
    }

    func get(firebase: String, path: String, callback: ([String:AnyObject]?, NSError?) -> Void) {
        if (self.dataTokens[firebase] != nil) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)

            let components = NSURLComponents()
            components.scheme = "https"
            components.host = "\(firebase).firebaseio.com"
            components.path = path

            components.queryItems = [
                    NSURLQueryItem(name: "auth", value: self.dataTokens[firebase]!),
                    NSURLQueryItem(name: "shallow", value: "true")
            ]

            let request = NSMutableURLRequest(URL: components.URL!)
            let task = session.dataTaskWithRequest(request) {
                (data, response, error) -> Void in
                if (error != nil) {
                    callback(nil, error)
                } else {
                    print("data: \(NSString(data: data!, encoding: NSUTF8StringEncoding))")
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let dictionary = result as? [String:AnyObject] {
                            callback(dictionary, nil)
                        } else {
                            callback(nil, nil)
                        }
                    } catch let error as NSError {
                        if(error.code == 3840) {
                            let value = NSString(data: data!, encoding: NSUTF8StringEncoding) as String!
                            callback([value: true], nil)
                        } else {
                            callback(nil, error)
                        }
                    }
                }
            }
            task.resume()
        } else {
            login({(auth, error) -> Void in
                self.account(callback)
            })
        }
    }
}
