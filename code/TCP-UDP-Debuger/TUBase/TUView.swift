//
//  TUView.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/21.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

extension UIView {
    
    func allSubViews() -> [UIView] {
        var items = [UIView]()
        for v in self.subviews {
            items.append(v)
            if v.subviews.count > 0 {
                items.appendContentsOf(v.allSubViews())
            }
        }
        return items
    }
    
    func viewHeightWithLimitWidth(limitWidth: CGFloat) -> CGFloat {
        
        self.bounds = CGRectMake(0.0, 0.0, limitWidth, CGRectGetHeight(self.bounds));
        
        self.layoutIfNeeded()
        
        for v in self.allSubViews() {
            if let lab = v as? UILabel {
                lab.preferredMaxLayoutWidth = lab.bounds.size.width
            }
        }
        
        return self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height;

    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var rect = self.frame
            rect.size.width = newValue
            self.frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var rect = self.frame
            rect.size.height = newValue
            self.frame = rect
        }
    }
    
    var X: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var rect = self.frame
            rect.origin.x = newValue
            self.frame = rect
        }
    }
    
    var Y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue
            self.frame = rect
        }
    }
}
