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
    static var sessionItems: [TUSession] {
        var items = PINCache.sharedCache().objectForKey(TUCacheKey.SessionItems) as? [TUSession]
        if items == nil {
            items = Array<TUSession>()
            PINCache.sharedCache().setObject(items!, forKey: TUCacheKey.SessionItems, block: nil)
        }
        return items!
    }
}