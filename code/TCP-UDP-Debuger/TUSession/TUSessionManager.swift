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


typealias TUSessionConnectionBlock = (connection: TUSessionConnection, event: TUSessionConnectionEven, tag: Int?, packet: TUPacket?) -> Void

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
        
        switch session.sessionProtocol {
        case .TCP:
            
            
            if self.tcpSocket == nil {
                self.tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            }
            
            if (self.tcpSocket?.isConnected != nil) {
                if session.isRandomLocalPort {
                    // 连接，本地随机端口
                    try! self.tcpSocket?.connectToHost(session.targetIP, onPort: UInt16(session.targetPort))
                } else {
                    // 连接，指定本地端口
                    try! self.tcpSocket?.connectToHost(session.targetIP, onPort: UInt16(session.targetPort), viaInterface: ":\(session.localPort)", withTimeout: 10)
                }
                self.tcpSocket?.readDataWithTimeout(-1, tag: 0)
            }
        case .UDP:
            if self.udpSocket == nil {
                self.udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            }
            
            if self.udpSocket!.isClosed() {
                if session.isRandomLocalPort {
                    // 侦听，随机本地端口
                    do {
                        try self.udpSocket?.bindToPort(0)
                        self.callBackStore?(connection: self, event: .Connected, tag: nil, packet: nil)
                    } catch {
                        self.callBackStore?(connection: self, event: .Didconnected, tag: nil, packet: nil)
                    }

                } else {
                    // 侦听，指定本机端口
                    do {
                        try self.udpSocket?.bindToPort(UInt16(session.localPort))
                        try self.udpSocket?.receiveOnce()
                        self.callBackStore?(connection: self, event: .Connected, tag: nil, packet: nil)
                    } catch {
                        self.callBackStore?(connection: self, event: .Didconnected, tag: nil, packet: nil)
                    }
                }
            }
        }
    }
    
    func disconnect() {
        if self.tcpSocket != nil {
            self.tcpSocket?.disconnect()
        }
        if self.udpSocket != nil {
            self.udpSocket?.close()
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
                self.udpSocket?.sendData(data, toHost: session.targetIP, port: UInt16(session.targetPort), withTimeout: timeout, tag: tag)
            }
        }
    }
    
    /**
        TCP Socket
    */
    @objc func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        // 连接成功
        print("TCP:连接成功: \(host)")
        self.callBackStore?(connection: self, event: .Connected, tag: nil, packet: nil)
    }
    @objc func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        // 断开连接
        print("TCP:连接断开")
        self.callBackStore?(connection: self, event: .Didconnected, tag: nil, packet: nil)
    }
    @objc func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        // 读取到数据
        print("TCP:收到数据")
        let packet = TUPacket(data: data, fromHost:sock.connectedHost, targetHost: sock.localHost)
        self.callBackStore?(connection: self, event: .ReadData, tag: tag, packet: packet)
        sock.readDataWithTimeout(-1, tag: 0)
    }
    @objc func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        // 写入数据成功
        print("TCP:数据发送成功")
        self.callBackStore?(connection: self, event: .WriteData, tag: nil, packet: nil)
    }
    
    /**
        UDP Socket
    */
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("UDP:数据发送成功")
        self.callBackStore?(connection: self, event: .WriteData, tag: nil, packet: nil)
    }
    @objc func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        print("UDP:连接断开")
        self.callBackStore?(connection: self, event: .Didconnected, tag: nil, packet: nil)
    }
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        print("UDP:收到数据")
        let packet = TUPacket(data: data, fromHost:String(data: address, encoding: NSUTF8StringEncoding) ?? "", targetHost: sock.localHost())
        self.callBackStore?(connection: self, event: .ReadData, tag: nil, packet: packet)
        try! self.udpSocket?.receiveOnce()
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