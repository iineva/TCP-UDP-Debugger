//
//  TUPacket.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/30.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation

class TUPacket {
    
    // 包数据
    var data: NSData
    
    // 数据来源主机
    var fromHost: String
    
    // 目标主机
    var targetHost: String
    
    init(data dataV: NSData, fromHost: String, targetHost: String) {
        self.data = dataV
        self.fromHost = fromHost
        self.targetHost = targetHost
    }
}