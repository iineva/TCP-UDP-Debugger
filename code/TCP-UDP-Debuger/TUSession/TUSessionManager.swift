//
//  TUSessionManager.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/22.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

enum TUSessionConnectionEven {
    case Connected, Didconnected, ReadData, WriteData
}


typealias TUSessionConnectionBlock = (connection: TUSessionConnection, event: TUSessionConnectionEven, tag: Int?, data: NSData?) -> Void

class TUSessionConnection: GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate {
    
    let timeout: NSTimeInterval = 10
    
    let session: TUSession
    
    var tcpSocket: GCDAsyncSocket?
    var udpSocket: GCDAsyncUdpSocket?
    
    var receiveBuffer = [UInt8]()
    var sendDataBuffer = [UInt8]()
    
    private var callBackStore: TUSessionConnectionBlock?
    func callBack(block: TUSessionConnectionBlock) {
        callBackStore = block
    }
    
    init(_ session: TUSession) {
        self.session = session
    }
    
    func connect() {
        
        if session.targetIP == nil {
            // TODO 却少目标IP
            print("却少目标IP")
            return
        }
        if session.targetPort == nil {
            // TODO 提示设置错误
            print("却少目标端口")
            return
        }
        
        switch session.sessionProtocol {
        case .TCP:
            if self.tcpSocket == nil {
                self.tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            }
            if (self.tcpSocket?.isConnected != nil) {
                try! self.tcpSocket?.connectToHost(session.targetIP, onPort: session.targetPort!)
                self.tcpSocket?.readDataWithTimeout(-1, tag: 0)
            }
        case .UDP:
            if self.udpSocket == nil {
                self.udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            }
            if (self.udpSocket?.isConnected == nil) {
                try! self.udpSocket?.connectToHost(session.targetIP, onPort: session.targetPort!)
            }
        }
    }
    
    func sendData(data: NSData, tag: Int) {
        switch session.sessionProtocol {
        case .TCP:
            if self.tcpSocket != nil && self.tcpSocket?.isConnected != nil {
                self.tcpSocket?.writeData(data, withTimeout: timeout, tag: tag)
            }
        case .UDP:
            if self.udpSocket != nil && self.udpSocket?.isConnected != nil {
                self.udpSocket?.sendData(data, withTimeout: timeout, tag: tag)
            }
        }

    }
    
    @objc func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        // 连接成功
        print("连接成功: \(host)")
        self.callBackStore?(connection: self, event: .Connected, tag: nil, data: nil)
    }
    @objc func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        // 断开连接
        print("连接断开")
        self.callBackStore?(connection: self, event: .Didconnected, tag: nil, data: nil)
    }
    @objc func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        // 读取到数据
        print("收到数据")
        self.callBackStore?(connection: self, event: .ReadData, tag: tag, data: data)
        sock.readDataWithTimeout(-1, tag: 0)
    }
    @objc func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        // 写入数据成功
        print("数据发送成功")
        self.callBackStore?(connection: self, event: .WriteData, tag: nil, data: nil)
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
        self.connection?.connect()
    }
}