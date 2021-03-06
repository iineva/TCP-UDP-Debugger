//
//  TUAddSessionViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// 添加会话控制器
class TUAddSessionViewController: TUBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 是否多连接
    var isMultiLink         = false
    // 多连接,连接数
    var linkCount           = 5
    // 多连接选项: 目标IP递增
    var multiLinkOptionsTargetIPIncrement    = false
    // 多连接选项: 目标端口递增
    var multiLinkOptionsTargetPortIncrement    = false
    // 多连接选项: 本地端口递增
    var multiLinkOptionsLocalPortIncrement    = false

    // 当前设置的会话信息
    var session = TUSession()
    
    // 编辑模式
    var editMode = false
    
    @IBAction func onSaveButtonTouch(sender: AnyObject) {
        // TODO 参数校验
        
        if editMode {
            
            // 保存编辑模式数据
            TUCache.shared.sessionItems = TUCache.shared.sessionItems
            
        } else {
            
            // 保存多链接创建
            if self.isMultiLink {
                
                var items = TUCache.shared.sessionItems
                
                for i in 0..<self.linkCount {
                    // 多连接选项: 目标IP递增
                    if multiLinkOptionsTargetIPIncrement {
                        // TODO IP 递增
                    }
                    // 多连接选项: 目标端口递增
                    if multiLinkOptionsTargetPortIncrement {
                        let session = TUSession(self.session)
                        session.targetPort += i
                        items.insert(session, atIndex: 0)
                    }
                    // 多连接选项: 本地端口递增(不启用随机端口才有效)
                    if multiLinkOptionsLocalPortIncrement && !self.session.isRandomLocalPort {
                        let session = TUSession(self.session)
                        session.localPort += i
                        items.insert(session, atIndex: 0)
                    }
                }
                
                TUCache.shared.sessionItems = items
                
            } else {
            
                // 保存单链接数据
                TUCache.shared.sessionItems.insert(self.session, atIndex: 0)
            
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var titleItems : [String] {
        get {
            if self.session.mode == .TCPServer {
                return ["模式", "服务器IP(本地IP)", "服务器端口(本地端口)", "自动断开和客户端的连接(s)", "每次发送字节大小(byte)", "数据接收缓冲大小(byte)", "数据包队列发送间隔(ms)"]
            } else {
                return ["模式", "目标IP和端口", "本地端口", "多个链接选项", "每次发送字节大小(byte)", "数据接收缓冲大小(byte)", "数据包队列发送间隔(ms)"]
            }
        }
    }
    
    // 协议选择器
    @IBOutlet weak var protocolSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化协议的选择
        protocolSegmented.selectedSegmentIndex = self.session.sessionProtocol.rawValue
        protocolSegmented.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext {
            [unowned self] (s) -> Void in
            if s.selectedSegmentIndex == 0 {
                self.session.sessionProtocol = .TCP
            } else {
                self.session.sessionProtocol = .UDP
            }
            self.tableView.reloadData()
        }        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.session.mode == .TCPServer {
            switch section {
            case 3:
                if self.session.isAutoDisconnectLinkDelay {
                    return 2
                } else {
                    return 1
                }
            default:
                return 1
            }
        }
        
        switch section {
        case 2:
            if self.session.isRandomLocalPort {
                return 1
            } else {
                return 2
            }
        case 3:
            if self.isMultiLink {
                return 3
            } else {
                return 1
            }
        default:
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.titleItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titleItems[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /**
        *  TCPServer模式
        */
        if self.session.mode == .TCPServer {
            switch indexPath.section {
            case 0: // 模式
                return self.getSegmentCell(indexPath)
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
                if let inputCell = cell as? TUAddSessionInputTableViewCell {
                    inputCell.inputV.placeholder = "(本地IP)"
                    inputCell.inputV.enabled = false
                    inputCell.inputV.text = UIDevice.localAddress()
                }
                return cell
            case 2: // 本地端口
                let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
                if let inputCell = cell as? TUAddSessionInputTableViewCell {
                    inputCell.inputV.placeholder = "请输入本地端口"
                    inputCell.inputV.enabled = true
                    inputCell.inputV.text = String(self.session.localPort)
                    inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self](x) -> Void in
                        if let s = x as? String {
                            if let p = Int(s) {
                                self.session.localPort = p
                            } else {
                                self.session.localPort = 0
                            }
                        }
                    })
                }
                return cell
            case 3: // 间隔多少秒自动断开和客户端的连接
                if indexPath.row == 0 { // 开关
                    let cell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath)
                    if let switchCell = cell as? TUAddSessionSwitchCell {
                        switchCell.titleLab.text = "自动断开和客户端的连接"
                        switchCell.switchV.on = self.session.isAutoDisconnectLinkDelay
                        switchCell.switchV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                            [unowned self, weak switchCell] (s) -> Void in
                            self.session.isAutoDisconnectLinkDelay = switchCell!.switchV.on
                            let indexPaths = [NSIndexPath(forRow: 1, inSection: indexPath.section)]
                            if self.session.isAutoDisconnectLinkDelay {
                                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                            } else {
                                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                        })
                    }
                    return cell
                } else { // 输入
                    let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
                    if let inputCell = cell as? TUAddSessionInputTableViewCell {
                        inputCell.inputV.placeholder = "请输入自动断开时间"
                        inputCell.inputV.enabled = true
                        inputCell.inputV.text = String(self.session.autoDisconnectLinkDelay) ?? ""
                        inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                            [unowned self, weak inputCell](x) -> Void in
                            self.session.autoDisconnectLinkDelay = Int(inputCell?.inputV.text ?? "") ?? 30
                        })
                    }
                    return cell
                }
            default:
                return self.getDefaultCell(indexPath)
            }
        }
        
        /**
        *  其他模式
        */
        switch indexPath.section {
        case 0: // 模式
            return self.getSegmentCell(indexPath)
        case 1: // 目标IP和端口
            let cell = tableView.dequeueReusableCellWithIdentifier("ip+port", forIndexPath: indexPath)
            if let IPPortCell = cell as? TUAddSessionIPAndPortCell {
                
                IPPortCell.IPLab.enabled = !(self.session.mode == .UDPBroadcast)
                IPPortCell.IPLab.text = self.session.targetIP
                IPPortCell.protLab.text = String(self.session.targetPort)
                IPPortCell.IPLab.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self](x) -> Void in
                    // TODO IP格式检验
                    if let v = x as? String {
                        self.session.targetIP = v
                    }
                })
                IPPortCell.protLab.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self](x) -> Void in
                    // TODO 端口格式检验
                    if let s = x as? String {
                        if let p = Int(s) {
                            self.session.targetPort = p
                        } else {
                            self.session.targetPort = 0
                        }
                    }
                })
            }
            return cell
        case 2: // 本地端口
            if indexPath.row == 0 { // 开关
                let cell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath)
                if let switchCell = cell as? TUAddSessionSwitchCell {
                    switchCell.titleLab.text = "随机本地端口"
                    switchCell.switchV.on = self.session.isRandomLocalPort
                    switchCell.switchV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak switchCell] (s) -> Void in
                        self.session.isRandomLocalPort = switchCell!.switchV.on
                        let indexPaths = [NSIndexPath(forRow: 1, inSection: indexPath.section)]
                        if self.session.isRandomLocalPort {
                            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                        } else {
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                        }
                        self.tableView.reloadSections(NSIndexSet(index: indexPath.section+1), withRowAnimation: UITableViewRowAnimation.Fade)
                    })
                }
                return cell
            } else { // 输入
                let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
                if let inputCell = cell as? TUAddSessionInputTableViewCell {
                    inputCell.inputV.placeholder = "请输入本地端口"
                    inputCell.inputV.enabled = true
                    inputCell.inputV.text = String(self.session.localPort)
                    inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self](x) -> Void in
                        if let s = x as? String {
                            if let p = Int(s) {
                                self.session.localPort = p
                            } else {
                                self.session.localPort = 0
                            }
                        }
                    })
                }
                return cell
            }
        case 3: // 多个链接选项
            if indexPath.row == 0 { // 开关
                let cell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath)
                if let switchCell = cell as? TUAddSessionSwitchCell {
                    switchCell.titleLab.text = "创建多个链接"
                    switchCell.switchV.on = self.isMultiLink
                    switchCell.switchV.enabled = !self.editMode
                    switchCell.switchV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak switchCell] (s) -> Void in
                        self.isMultiLink = switchCell!.switchV.on
                        let indexPaths = [NSIndexPath(forRow: 1, inSection: indexPath.section), NSIndexPath(forRow: 2, inSection: indexPath.section)]
                        if self.isMultiLink {
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                        } else {
                            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                        }
                    })
                }
                return cell
            } else if indexPath.row == 1 { // 输入创建连接数量
                let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
                if let inputCell = cell as? TUAddSessionInputTableViewCell {
                    inputCell.inputV.placeholder = "请输入创建数量"
                    inputCell.inputV.text = String(self.linkCount)
                    inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self](x) -> Void in
                        if let s = x as? String {
                            if let p = Int(s) {
                                self.linkCount = p
                            } else {
                                self.linkCount = 0
                            }
                        }
                    })
                }
                return cell
            } else { // 选择多连接选项
                let cell = tableView.dequeueReusableCellWithIdentifier("selector", forIndexPath: indexPath)
                if let selectorCell = cell as? TUAddSessionSelectorCell {
                    
                    // 目标IP递增
                    selectorCell.button1.selected = self.multiLinkOptionsTargetIPIncrement
                    // 目标端口递增
                    selectorCell.button2.selected = self.multiLinkOptionsTargetPortIncrement
                    // 本地端口递增
                    selectorCell.button3.selected = self.multiLinkOptionsLocalPortIncrement
                    selectorCell.button3.enabled = !self.session.isRandomLocalPort
                    
                    // 响应选中和取消选中
                    selectorCell.button1.rac_signalForControlEvents(UIControlEvents.TouchUpInside).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak selectorCell] (s) -> Void in
                        selectorCell!.button1.selected = !selectorCell!.button1.selected
                        self.multiLinkOptionsTargetIPIncrement = selectorCell!.button1.selected
                    })
                    selectorCell.button2.rac_signalForControlEvents(UIControlEvents.TouchUpInside).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak selectorCell] (s) -> Void in
                        selectorCell!.button2.selected = !selectorCell!.button2.selected
                        self.multiLinkOptionsTargetPortIncrement = selectorCell!.button2.selected
                    })
                    selectorCell.button3.rac_signalForControlEvents(UIControlEvents.TouchUpInside).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak selectorCell] (s) -> Void in
                        selectorCell!.button3.selected = !selectorCell!.button3.selected
                        self.multiLinkOptionsLocalPortIncrement = selectorCell!.button3.selected
                    })
                }
                return cell
            }
        default:
            return self.getDefaultCell(indexPath)
        }
    }
    
    // 获取通用默认Cell
    func getDefaultCell(indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 4: // 每次发送字节大小
            let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
            if let inputCell = cell as? TUAddSessionInputTableViewCell {
                inputCell.inputV.placeholder = "请输入每次发送字节大小"
                inputCell.inputV.enabled = true
                inputCell.inputV.text = String(self.session.sendPackgetSize)
                inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self, weak inputCell](x) -> Void in
                    self.session.sendPackgetSize = Int(inputCell?.inputV.text ?? "") ?? 0
                })
            }
            return cell
        case 5: // 数据接收缓冲大小
            let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
            if let inputCell = cell as? TUAddSessionInputTableViewCell {
                inputCell.inputV.placeholder = "请输入数据接收缓冲大小"
                inputCell.inputV.enabled = true
                inputCell.inputV.text = String(self.session.receiveBufferSize)
                inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self, weak inputCell](x) -> Void in
                    self.session.receiveBufferSize = Int(inputCell?.inputV.text ?? "") ?? 0
                })
            }
            return cell
        case 6: // 数据包队列发送间隔
            let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
            if let inputCell = cell as? TUAddSessionInputTableViewCell {
                inputCell.inputV.placeholder = "请输入数据包队列发送间隔"
                inputCell.inputV.enabled = true
                inputCell.inputV.text = String(self.session.sendQueueDelay)
                inputCell.inputV.rac_newTextChannel().takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self, weak inputCell](x) -> Void in
                    self.session.sendQueueDelay = Int(inputCell?.inputV.text ?? "") ?? 0
                })
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // 获取模式选择Cell
    func getSegmentCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mode", forIndexPath: indexPath)
        if let segmented = cell as? TUAddSessionSegmentedCell {
            
            segmented.segmentedV.removeAllSegments()
            
            if self.session.sessionProtocol == .TCP {
                segmented.segmentedV.insertSegmentWithTitle("客户端模式", atIndex: 0, animated: false)
                segmented.segmentedV.insertSegmentWithTitle("服务器模式", atIndex: 1, animated: false)
                switch self.session.mode {
                case .TCPServer:
                    segmented.segmentedV.selectedSegmentIndex = 1
                default:
                    segmented.segmentedV.selectedSegmentIndex = 0
                }
                
                segmented.segmentedV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self, weak segmented](x) -> Void in
                    self.session.mode = segmented?.segmentedV.selectedSegmentIndex == 0 ? .TCPClient : .TCPServer
                    self.tableView.reloadData()
                })
                
            } else {
                segmented.segmentedV.insertSegmentWithTitle("普通模式", atIndex: 0, animated: false)
                segmented.segmentedV.insertSegmentWithTitle("组播模式", atIndex: 1, animated: false)
                segmented.segmentedV.insertSegmentWithTitle("广播模式", atIndex: 2, animated: false)
                switch self.session.mode {
                case .UDPGrup:
                    segmented.segmentedV.selectedSegmentIndex = 1
                case .UDPBroadcast:
                    segmented.segmentedV.selectedSegmentIndex = 2
                default:
                    segmented.segmentedV.selectedSegmentIndex = 0
                }
                
                segmented.segmentedV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                    [unowned self, weak segmented](x) -> Void in
                    switch segmented!.segmentedV.selectedSegmentIndex {
                    case 1:
                        self.session.mode = .UDPGrup
                    case 2:
                        self.session.mode = .UDPBroadcast
                    default:
                        self.session.mode = .UDPNormal
                    }
                    self.tableView.reloadData()
                })
            }
        }
        return cell
    }
}

    