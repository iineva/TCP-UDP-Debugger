//
//  TUCache.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/19.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation
import PINCache

private struct TUCacheKey {
    static let SessionItems = "SessionItems" // 保存本地回话
}

class TUCache {
    
    // 单例模式
    class var shared : TUCache {
        struct Static { static let instance = TUCache() }
        return Static.instance
    }
    
    init() {
        // 初始化
        if let items = PINCache.sharedCache().objectForKey(TUCacheKey.SessionItems) as? [TUSession] {
            sessionItems = items
        }
    }
    
    var sessionItems = [TUSession]() {
        didSet {
            PINCache.sharedCache().setObject(sessionItems, forKey: TUCacheKey.SessionItems, block: nil)
        }
    }
}