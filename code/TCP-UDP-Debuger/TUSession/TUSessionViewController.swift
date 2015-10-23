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
class TUSessionViewController: TUBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    var isConnected = false
    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    deinit {
        self.connection?.disconnect()
    }
    
    @IBOutlet weak var topRightItem: UIBarButtonItem!
    @IBAction func onTopRightItemTouch(sender: AnyObject) {
        if isConnected {
            self.connection?.disconnect()
        } else {
            self.connection?.connect()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.connection?.callBack({
                [weak self] (connection, event: TUSessionConnectionEven, tag, data) -> Void in
                self?.connectCallBack(connection, event: event, tag: tag, data: data)
            })
            self.title = "\(self.session!.targetIP):\(self.session!.targetPort)"
            self.startConnect()
        }
    }
    
    // 连接
    func startConnect() {
        self.topRightItem.enabled = false
        AFMInfoBanner.showAndHideWithText("正在连接...", style: AFMInfoBannerStyle.Info)
        self.connection?.connect()
    }
    
    func connectCallBack(connection: TUSessionConnection, event: TUSessionConnectionEven, tag: Int?, data: NSData?) {
        switch event {
        case .Connected:
            isConnected = true
            AFMInfoBanner.showAndHideWithText("连接成功", style: AFMInfoBannerStyle.Info)
            self.topRightItem.title = "断开连接"
            self.topRightItem.enabled = true
        case .Didconnected:
            isConnected = false
            AFMInfoBanner.showAndHideWithText("连接断开", style: AFMInfoBannerStyle.Error)
            self.topRightItem.title = "点击连接"
            self.topRightItem.enabled = true
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
            break
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