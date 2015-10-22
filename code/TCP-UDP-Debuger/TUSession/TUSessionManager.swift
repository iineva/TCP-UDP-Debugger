//
//  TUSessionManager.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/22.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class TUSessionConnection: GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate {
    
    let session: TUSession
    
    var tcpSocket: GCDAsyncSocket?
    var udpSocket: GCDAsyncUdpSocket?
    
    init(_ session: TUSession) {
        self.session = session
        if session.sessionProtocol == .TCP {
            self.tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        } else {
            self.udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
    }
    
    @objc func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        // 连接成功
    }
    @objc func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        // 断开连接
    }
    @objc func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        // 读取到数据
    }
    @objc func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        // 写入数据成功
    }
}

/// 连接管理器
class TUSessionManager {

    // 单例模式
    class var shared : TUSessionManager {
        struct Static { static let instance = TUSessionManager() }
        return Static.instance
    }
    
    var connection: TUSessionConnection?
    
    func start(session: TUSession) {
        
        self.connection = TUSessionConnection(session)
        
        
    }
}