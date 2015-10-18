//
//  TUSession.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/18.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation

/**
会话协议

- TCP: TCP
- UDP: UDP
*/
enum TUSessionProtocol: Int {
    case TCP = 0, UDP
}

/// 多连接选项
struct TUSessionMultiLinkOptions: OptionSetType {
    let rawValue: Int
    
    // 无
    static let None                 = TUSessionMultiLinkOptions(rawValue: 0)
    
    // 目标IP递增
    static let TargetIPIncrement    = TUSessionMultiLinkOptions(rawValue: 1 << 0)
    
    // 目标端口递增
    static let TargetPortIncrement  = TUSessionMultiLinkOptions(rawValue: 1 << 1)
    
    // 本地端口递增
    static let LocalPortIncrement   = TUSessionMultiLinkOptions(rawValue: 1 << 2)
}

/// 会话信息
class TUSession {
    
    // 会话协议
    var sessionProtocol = TUSessionProtocol.TCP
    
    // 目标IP
    var targetIP:   String?
    
    // 目标端口
    var targetPort: String?
    
    // 本地端口
    var localPort:  String?
    
    // 是否随机本地端口
    var isRandomLocalPort   = false
    
    // 发送每个包的大小
    var sendPackgetSize     = 1024 * 2
    
    // 数据接收大小
    var receiveBufferSize   = 1024 * 1024
    
    // 数据队列发送延时(ms)
    var sendQueueDelay      = 20
    
    // 连接数
    var linkCount           = 1
    
    // 多连接选项
    var multiLinkOptions    = TUSessionMultiLinkOptions()
}