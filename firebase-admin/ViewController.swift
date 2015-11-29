//
//  ViewController.swift
//  firebase-admin
//
//  Created by Chris Ellsworth on 11/22/15.
//  Copyright © 2015 Chris Ellsworth. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    var api: FirebaseAPI?

    var firebases = [[String: AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.toggleActivityIndicator(true)

        self.api = FirebaseAPI()

        api?.login({
            (token, error) -> Void in
            if (error != nil) {
                print("error: \(error!)")
            } else {
                self.api?.account({
                    (account, error) -> Void in
                    if (error != nil) {
                        print("error: \(error!)")
                    } else {
                        let raw = account!["firebases"] as! [String:[String:AnyObject]]
                        for value in raw.values {
                            self.firebases.append(value)
                        }
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.tableView.reloadData()
                            self.toggleActivityIndicator(false)
                        })
                    }
                })
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(cell)
            if (indexPath != nil) {
                if let destination = segue.destinationViewController as? DataViewController {
                    destination.api = self.api
                    destination.firebase = self.firebases[indexPath!.row]
                    destination.path = ""
                }
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("firebase", forIndexPath: indexPath)
        cell.textLabel?.text = self.firebases[indexPath.row]["firebaseName"] as! String?
        cell.detailTextLabel?.text = self.firebases[indexPath.row]["role"] as! String?
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firebases.count
    }

    func toggleActivityIndicator(visible: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = visible
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

