//
//  TUSessionViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import SnapKit

/// 会话控制器
class TUSessionViewController: TUBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var session : TUSession?
    var connection: TUSessionConnection?
    var toolbar: TUInputToolbar?
    var recieveData = NSMutableData() {
        didSet {
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    var recieveDataItems = [NSData]()
    var isConnected = false
    
    var isHexMode = false
    var isChatMode = false
    
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        JDStatusBarNotification.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加入输入框
        toolbar = TUInputToolbar.create()
        toolbar?.sendStirng({
            [unowned self](string) -> Void in
            if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
                // 发送输入的文字
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
                [weak self] (connection, event: TUSessionConnectionEven, tag, packet) -> Void in
                self?.connectCallBack(connection, event: event, tag: tag, packet: packet)
            })
            self.title = "\(self.session!.targetIP):\(self.session!.targetPort)"
            self.startConnect()
        }
    }
    
    // 连接
    func startConnect() {
        self.topRightItem.enabled = false
        
        JDStatusBarNotification.showWithStatus("正在连接...")
        JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.connection?.connect()
    }
    
    func connectCallBack(connection: TUSessionConnection, event: TUSessionConnectionEven, tag: Int?, packet: TUPacket?) {
        switch event {
        case .Connected:
            isConnected = true
            JDStatusBarNotification.showWithStatus("连接成功", dismissAfter: 1, styleName:JDStatusBarStyleSuccess)
            self.topRightItem.title = "断开连接"
            self.topRightItem.enabled = true
        case .Didconnected:
            isConnected = false
            JDStatusBarNotification.showWithStatus("连接断开", dismissAfter: 1, styleName:JDStatusBarStyleWarning)
            self.topRightItem.title = "点击连接"
            self.topRightItem.enabled = true
        case .ReadData:
            if let p = packet {
                // 接收到数据
                self.recieveDataItems.append(p.data)
                self.recieveData.appendData(p.data)
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("menu") as? TUSessionMenuCell {
            
            view.addSubview(cell)
            
            // 相应menu按钮
            cell.hexButton.selected = self.isHexMode
            cell.hexButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext({
                [weak self](x) -> Void in
                if let button = x as? UIButton {
                    button.selected = !button.selected
                    self?.isHexMode = button.selected
                    self?.tableView.reloadData()
                }
            })
            cell.chatModeButton.selected = self.isChatMode
            cell.chatModeButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext({
                [weak self](x) -> Void in
                if let button = x as? UIButton {
                    button.selected = !button.selected
                    self?.isChatMode = button.selected
                    self?.tableView.reloadData()
                }
            })
            
            // 添加约束
            cell.snp_makeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(view)
            })
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellForIndexPath(nil).viewHeightWithLimitWidth(tableView.frame.size.width)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellForIndexPath(indexPath)
    }
    
    func cellForIndexPath(indexPath: NSIndexPath?) -> UITableViewCell {
        
        var cell : UITableViewCell? = nil;
        if let index = indexPath {
            cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: index)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("cell")
        }
        
        if let c = cell as? TUSessionLabelCell {
            if self.isHexMode {
                c.contentLab.text = self.recieveData.hexString;
            } else {
                c.contentLab.text = String(data: self.recieveData, encoding: NSUTF8StringEncoding)
            }
        }
        return cell!
    }
}