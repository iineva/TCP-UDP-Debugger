//
//  TUViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

class TUViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func pushViewController(key: String) -> UIViewController? {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(key)
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        return vc
    }
    
    @IBAction func onAddButtonTouch(sender: UIButton) {
        self.pushViewController("TUAddSessionViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // 编辑
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "编辑") {
            [unowned self](_, _) -> Void in
            if let vc = self.pushViewController("TUAddSessionViewController") as? TUAddSessionViewController {
                vc.session = TUCache.shared.sessionItems[indexPath.row]
            }
        }
        editAction.backgroundColor = self.navigationController?.navigationBar.tintColor
        
        // 删除
        let delAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "删除") {
            (_, _) -> Void in
            TUCache.shared.sessionItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        return [delAction, editAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TUCache.shared.sessionItems.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let vc = self.pushViewController("TUSessionViewController") as? TUSessionViewController {
            vc.session = TUCache.shared.sessionItems[indexPath.row]
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if let c = cell as? TUViewControllerCell {
            c.setInfo(TUCache.shared.sessionItems[indexPath.row])
        }
        return cell
    }

}