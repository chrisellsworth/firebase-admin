//
//  DataViewController.swift
//  firebase-admin
//
//  Created by Chris Ellsworth on 11/27/15.
//  Copyright © 2015 Chris Ellsworth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class DataViewController: UITableViewController {

    var api: FirebaseAPI!
    var ref: Firebase!
    var firebaseDataSource: FirebaseTableViewDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        let components = NSURLComponents(string: self.ref.description)
        let firebase = components!.host!.componentsSeparatedByString(".")[0]
        
        self.title = "\(firebase)\(components!.path!)"

        self.toggleActivityIndicator(true)
        api.token(firebase, callback: {
            (token, error) -> Void in
            if (error != nil) {
                print("error: \(error)")
                self.toggleActivityIndicator(false)
            } else if (token != nil) {
                print("token: \(token)")

                let personalToken = token!["personalToken"] as! String

                self.ref.authWithCustomToken(personalToken, withCompletionBlock: {
                    (error, auth) -> Void in
                    if (error != nil) {
                        print("error: \(error)")
                        self.toggleActivityIndicator(false)
                    } else {
                        print("auth: \(auth)")

                        self.toggleActivityIndicator(false)
                        
                        self.firebaseDataSource = FirebaseTableViewDataSource(ref: self.ref, modelClass: FDataSnapshot.self, cellClass: DataTableViewCell.self, cellReuseIdentifier: "data", view: self.tableView)

                        self.firebaseDataSource.populateCellWithBlock({
                            (cell, object) -> Void in
                            let snap = object as! FDataSnapshot
                            cell.textLabel?.text = snap.ref.key
                            
                            if(snap.childrenCount == 0) {
                                cell.detailTextLabel?.text = "value: \(snap.value)"
                            } else {
                                cell.detailTextLabel?.text = "\(snap.childrenCount) children"
                            }
                            
                            
                            let dataCell = cell as! DataTableViewCell
                            dataCell.ref = snap.ref
                        })
                        
                        self.firebaseDataSource.cancelWithBlock({
                            (error) -> Void in
                            print("error: \(error)")
                        })
                        
                        self.tableView.dataSource = self.firebaseDataSource
                    }
                })

//                self.api.get(name, path: "/\(self.path!).json", callback: {
//                    (data, error) -> Void in
//                    if (error != nil) {
//                        print("error: \(error)")
//                    } else {
//                        print("data: \(data)")
//                        for key in data!.keys {
//                            self.data.append(key)
//                        }
//
//                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                            self.tableView.reloadData()
//                            self.toggleActivityIndicator(false)
//                        })
//                    }
//                });
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func toggleActivityIndicator(visible: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = visible
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? DataTableViewCell {
            let indexPath = self.tableView.indexPathForCell(cell)
            if (indexPath != nil) {
                if let destination = segue.destinationViewController as? DataViewController {
                    destination.api = self.api
                    destination.ref = cell.ref!
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier("ShowData", sender: cell)
    }

}
