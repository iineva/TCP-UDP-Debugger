//
//  TUBaseViewController.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/23.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

class TUBaseViewController: UIViewController {
    
    deinit {
        print("deinit: \(self.classForCoder)")
    }
}
