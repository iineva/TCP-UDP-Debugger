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
class TUAddSessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let session = TUSession()
    
    let titleItems = ["模式", "目标IP和端口", "本地端口", "多个链接选项", "每次发送字节大小(byte)", "数据接收缓冲大小(byte)", "数据包队列发送间隔(ms)"]
    
    // 协议选择器
    @IBOutlet weak var protocolSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化协议的选择
        protocolSegmented.selectedSegmentIndex = TUSessionProtocol.TCP.rawValue
        protocolSegmented.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext {
            [unowned self] (s) -> Void in
            self.session.sessionProtocol = TUSessionProtocol(rawValue: s.selectedSegmentIndex) ?? TUSessionProtocol.TCP
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            if self.session.isRandomLocalPort {
                return 1
            } else {
                return 2
            }
        case 3:
            if self.session.isMultiLink {
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
        switch indexPath.section {
        case 0: // 模式
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
                }
            }
            return cell
        case 1: // 目标IP和端口
            let cell = tableView.dequeueReusableCellWithIdentifier("ip+port", forIndexPath: indexPath)
            return cell
        case 2: // 本地端口
            if indexPath.row == 0 { // 开关
                let cell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath)
                if let switchCell = cell as? TUAddSessionSwitchCell {
                    switchCell.titleLab.text = "随机本地端口"
                    switchCell.switchV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak switchCell] (s) -> Void in
                        self.session.isRandomLocalPort = switchCell!.switchV.on
                        let indexPaths = [NSIndexPath(forRow: 1, inSection: 2)]
                        if self.session.isRandomLocalPort {
                            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                        } else {
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                        }
                    })
                }
                return cell
            } else { // 输入
                let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
                if let inputCell = cell as? TUAddSessionInputTableViewCell {
                    inputCell.inputV.placeholder = "请输入本地端口"
                }
                return cell
            }
        case 3: // 多个链接选项
            if indexPath.row == 0 { // 开关
                let cell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath)
                if let switchCell = cell as? TUAddSessionSwitchCell {
                    switchCell.titleLab.text = "创建多个链接"
                    switchCell.switchV.rac_signalForControlEvents(UIControlEvents.ValueChanged).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak switchCell] (s) -> Void in
                        self.session.isMultiLink = switchCell!.switchV.on
                        let indexPaths = [NSIndexPath(forRow: 1, inSection: 3), NSIndexPath(forRow: 2, inSection: 3)]
                        if self.session.isMultiLink {
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
                    inputCell.inputV.text = "\(self.session.linkCount)"
                }
                return cell
            } else { // 选择多连接选项
                let cell = tableView.dequeueReusableCellWithIdentifier("selector", forIndexPath: indexPath)
                if let selectorCell = cell as? TUAddSessionSelectorCell {
                    
                    // 目标IP递增
                    selectorCell.button1.selected = self.session.multiLinkOptionsTargetIPIncrement
                    // 目标端口递增
                    selectorCell.button2.selected = self.session.multiLinkOptionsTargetPortIncrement
                    // 本地端口递增
                    selectorCell.button3.selected = self.session.multiLinkOptionsLocalPortIncrement
                    
                    // 响应选中和取消选中
                    selectorCell.button1.rac_signalForControlEvents(UIControlEvents.TouchUpInside).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak selectorCell] (s) -> Void in
                        selectorCell!.button1.selected = !selectorCell!.button1.selected
                        self.session.multiLinkOptionsTargetIPIncrement = selectorCell!.button1.selected
                    })
                    selectorCell.button2.rac_signalForControlEvents(UIControlEvents.TouchUpInside).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak selectorCell] (s) -> Void in
                        selectorCell!.button2.selected = !selectorCell!.button2.selected
                        self.session.multiLinkOptionsTargetPortIncrement = selectorCell!.button2.selected
                    })
                    selectorCell.button3.rac_signalForControlEvents(UIControlEvents.TouchUpInside).takeUntil(cell.rac_prepareForReuseSignal).subscribeNext({
                        [unowned self, weak selectorCell] (s) -> Void in
                        selectorCell!.button3.selected = !selectorCell!.button3.selected
                        self.session.multiLinkOptionsLocalPortIncrement = selectorCell!.button3.selected
                    })
                }
                return cell
            }
        case 4: // 每次发送字节大小
            let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
            if let inputCell = cell as? TUAddSessionInputTableViewCell {
                inputCell.inputV.placeholder = "请输入每次发送字节大小"
                inputCell.inputV.text = "\(self.session.sendPackgetSize)"
            }
            return cell
        case 5: // 数据接收缓冲大小
            let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
            if let inputCell = cell as? TUAddSessionInputTableViewCell {
                inputCell.inputV.placeholder = "请输入数据接收缓冲大小"
                inputCell.inputV.text = "\(self.session.receiveBufferSize)"
            }
            return cell
        case 6: // 数据包队列发送间隔
            let cell = tableView.dequeueReusableCellWithIdentifier("input", forIndexPath: indexPath)
            if let inputCell = cell as? TUAddSessionInputTableViewCell {
                inputCell.inputV.placeholder = "请输入数据包队列发送间隔"
                inputCell.inputV.text = "\(self.session.sendQueueDelay)"
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

}