//
//  TUViewControllerCell.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/19.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

class TUViewControllerCell: UITableViewCell {
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var targetIPAndPort: UILabel!
    @IBOutlet weak var targetLocalPort: UILabel!
    
    func setInfo(session: TUSession) {
        switch session.mode {
        case .TCPClient:
            self.titleLab.text = "TCP客户端"
        case .TCPServer:
            self.titleLab.text = "TCP服务器"
        case .UDPNormal:
            self.titleLab.text = "UDP普通模式"
        case .UDPGrup:
            self.titleLab.text = "UDP组播"
        case .UDPBroadcast:
            self.titleLab.text = "UDP广播"
        }
        
        var targetIP = "";
        var targetPort = "";
        var localPort = "";
        
        if let v = session.targetIP {
            targetIP = v
        }
        if let v = session.targetPort {
            targetPort = String(v)
        }
        if let v = session.localPort {
            localPort = String(v)
        }
        
        self.targetIPAndPort.text = "\(targetIP):\(targetPort)"
        self.targetLocalPort.text = session.isRandomLocalPort ? "随机" : localPort
    }
}