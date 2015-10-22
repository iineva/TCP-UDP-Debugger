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
    
    @IBOutlet weak var bottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var session : TUSession?
    var connection: TUSessionConnection?
    var toolbar: TUInputToolbar?
    var recieveString = "" {
        didSet {
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    var recieveStirngItems = [String]()
    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO for test.
        AFMInfoBanner.showWithText("正在连接...", style: AFMInfoBannerStyle.Info, andHideAfter: 2)
        
        // 加入输入框
        toolbar = TUInputToolbar.create()
        toolbar?.sendStirng({
            [unowned self](string) -> Void in
            if let data = string.dataUsingEncoding(NSASCIIStringEncoding) {
                self.connection?.sendData(data, tag: 0)
            }
        })
        toolbar?.heightChange({
            [unowned self](height) -> Void in
            self.bottonConstraint.constant = height
        })
        toolbar?.showInView(self.view)
        
        // 连接
        if let s = self.session {
            self.connection = TUSessionConnection(s)
            self.connection?.connect()
            self.connection?.callBack({
                [unowned self] (connection, event: TUSessionConnectionEven, tag, data) -> Void in
                switch event {
                case .Connected:
                    AFMInfoBanner.showAndHideWithText("连接成功", style: AFMInfoBannerStyle.Info)
                case .Didconnected:
                    AFMInfoBanner.showAndHideWithText("连接断开", style: AFMInfoBannerStyle.Info)
                case .ReadData:
                    if let d = data {
                        if let s = NSString(data: d, encoding: NSASCIIStringEncoding) {
                            let string = String(s)
                            self.recieveString.appendContentsOf(string)
                            self.recieveStirngItems.append(string)
                            print(string)
                        }
                    }
                case .WriteData:
                    print(tag)
                }
            })
        }
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
            c.contentLab.text = self.recieveString
        }
        let height = cell!.contentView.viewHeightWithLimitWidth(tableView.frame.size.width)
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if let c = cell as? TUSessionLabelCell {
            c.contentLab.text = self.recieveString
        }
        return cell
    }
}