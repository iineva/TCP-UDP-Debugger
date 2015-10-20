//
//  TUSession.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/18.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation
import JSONModel

/**
会话协议

- TCP: TCP
- UDP: UDP
*/
enum TUSessionProtocol: Int {
    case TCP = 0, UDP
}

/**
连接模式
*/
enum TUSessionMode: Int {
    case TCPClient, TCPServer, UDPNormal, UDPGrup, UDPBroadcast
}

/// 会话信息
class TUSession: JSONModel {
    
    // 会话协议
    var sessionProtocol = TUSessionProtocol.TCP {
        willSet {
            switch mode {
            case .TCPClient, .TCPServer:
                if newValue == .UDP {
                    mode = .UDPNormal
                }
            case .UDPNormal, .UDPGrup, .UDPBroadcast:
                if newValue == .TCP {
                    mode = .TCPClient
                }
            }
        }
    }
    
    // 连接模式
    var mode = TUSessionMode.TCPClient {
        didSet {
            switch self.mode {
            case .TCPClient, .TCPServer:
                if sessionProtocol == .UDP {
                    mode = TUSessionMode.TCPClient
                }
            case .UDPNormal, .UDPGrup, .UDPBroadcast:
                if sessionProtocol == .TCP {
                    mode = TUSessionMode.UDPNormal
                }
            }
        }
    }
        
    // 目标IP
    private var targetIPStore: String?
    var targetIP: String? {
        get {
            if self.mode == .UDPBroadcast {
                return "255.255.255.255"
            } else {
                return targetIPStore
            }
        }
        set {
            if self.mode != .UDPBroadcast {
                targetIPStore = newValue
            }
        }
    }
    // 目标端口
    var targetPort: UInt16?
    
    // 是否随机本地端口
    var isRandomLocalPort   = false
    // 本地端口
    var localPort:  UInt16?
    
    // TCPServer模式，自动断开和客户端的连接时间(s)，0表示不断开
    var autoDisconnectLinkDelay = 30
    // TCPServer模式，是否自动断开和客户端的连接
    var isAutoDisconnectLinkDelay = false
    
    // 发送每个包的大小
    var sendPackgetSize     = 1024 * 2
    // 数据接收大小
    var receiveBufferSize   = 1024 * 1024
    // 数据队列发送延时(ms)
    var sendQueueDelay      = 20
    
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
}