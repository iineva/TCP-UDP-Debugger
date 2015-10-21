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

}
