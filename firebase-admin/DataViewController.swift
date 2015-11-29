//
//  DataViewController.swift
//  firebase-admin
//
//  Created by Chris Ellsworth on 11/27/15.
//  Copyright © 2015 Chris Ellsworth. All rights reserved.
//

import UIKit
import Firebase

class DataViewController: UITableViewController {

    var api: FirebaseAPI?
    var firebase: [String:AnyObject]?
    var path: String?
    var data = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let name = self.firebase?["firebaseName"] as! String
        self.title = "\(name)\(self.path!)"

        self.toggleActivityIndicator(true)
        api?.token(name, callback: {
            (token, error) -> Void in
            if (error != nil) {
                print("error: \(error)")
            } else if(token != nil) {
                print("token: \(token)")
                self.api?.get(name, path: "/\(self.path!).json", callback: {
                    (data, error) -> Void in
                    if (error != nil) {
                        print("error: \(error)")
                    } else {
                        print("data: \(data)")
                        for key in data!.keys {
                            self.data.append(key)
                        }

                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.tableView.reloadData()
                            self.toggleActivityIndicator(false)
                        })
                    }
                });
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("data", forIndexPath: indexPath)

        cell.textLabel?.text = self.data[indexPath.row]
        cell.detailTextLabel?.text = nil

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(cell)
            if (indexPath != nil) {
                if let destination = segue.destinationViewController as? DataViewController {
                    destination.api = self.api
                    destination.firebase = self.firebase
                    destination.path = "\(self.path!)/\(self.data[indexPath!.row])"
                }
            }
        }
    }

}
