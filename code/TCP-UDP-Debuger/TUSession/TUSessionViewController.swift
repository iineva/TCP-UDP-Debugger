//
//  TUSessionViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import AFMInfoBanner

/// 会话控制器
class TUSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var session : TUSession?
    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var contentString: String {
        get {
            return "xxxx"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO for test.
        AFMInfoBanner.showWithText("正在连接...", style: AFMInfoBannerStyle.Info, andHideAfter: 2)
        
        // 加入输入框
        TUInputToolbar.showInView(self.view!)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if let c = cell as? TUSessionLabelCell {
            c.contentLab.text = self.contentString
            c.contentLab.backgroundColor = UIColor.redColor()
        }
        let height = cell!.contentView.viewHeightWithLimitWidth(tableView.frame.size.width)
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if let c = cell as? TUSessionLabelCell {
            c.contentLab.text = self.contentString
        }
        return cell
    }
}