//
//  TUViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

class TUViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func pushViewController(key: String) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(key)
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func onAddButtonTouch(sender: UIButton) {
        self.pushViewController("AddSessionViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO 点击相应
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.pushViewController("SessionViewController")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }

}