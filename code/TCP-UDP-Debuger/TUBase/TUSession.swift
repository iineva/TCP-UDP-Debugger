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
    
    convenience init(_ session: TUSession) {
        self.init()
        self.sessionProtocol = session.sessionProtocol
        self.mode = session.mode
        self.targetIP = session.targetIP
        self.targetPort = session.targetPort
        self.isRandomLocalPort = session.isRandomLocalPort
        self.localPort = session.localPort
        self.autoDisconnectLinkDelay = session.autoDisconnectLinkDelay
        self.isAutoDisconnectLinkDelay = session.isAutoDisconnectLinkDelay
        self.sendPackgetSize = session.sendPackgetSize
        self.receiveBufferSize = session.receiveBufferSize
        self.sendQueueDelay = session.sendQueueDelay
    }
    
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
    private var targetIPStore = ""
    var targetIP: String {
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
    var targetPort: Int = 80
    
    // 是否随机本地端口
    var isRandomLocalPort   = false
    // 本地端口
    var localPort: Int = 8888
    
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
    
}