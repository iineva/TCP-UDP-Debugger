//
//  TUAddSessionViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// 添加会话
class TUAddSessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var session = TUSession()
    
    // 协议选择器
    @IBOutlet weak var protocolSegmented: UISegmentedControl!
    
    var keyItems : [String] {
        get {
            switch session.sessionProtocol {
            case .TCP:
                return ["mode", "target", "local"]
            case .UDP:
                return ["mode", "target", "local"]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化协议的选择
        protocolSegmented.selectedSegmentIndex = TUSessionProtocol.TCP.rawValue
        protocolSegmented.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext {
            [unowned self] (s) -> Void in
            self.session.sessionProtocol = TUSessionProtocol(rawValue: s.selectedSegmentIndex) ?? TUSessionProtocol.TCP
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keyItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.keyItems[indexPath.row], forIndexPath: indexPath)
        return cell
    }

}