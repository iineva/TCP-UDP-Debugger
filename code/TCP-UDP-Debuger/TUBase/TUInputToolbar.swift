//
//  TUInputToolbar.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/22.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import SnapKit

class TUInputToolbar: UIView, UITextViewDelegate {
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction private func onSendButtonTouch(sender: AnyObject) {
        if self.textView.text != nil {
            if let c = sendStirngStore {
                c(string: self.textView.text)
            }
        }
    }
    
    private var bottomConstraint: Constraint?
    
    // 文字修改回调
    private var sendStirngStore: ((string: String) -> Void)?
    func sendStirng(block: (string: String) -> Void) {
        sendStirngStore = block
    }
    
    // 高度改变回调
    private var heightChangeStore: ((height: CGFloat) -> Void)?
    func heightChange(block: (height: CGFloat) -> Void) {
        heightChangeStore = block
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendButton.layer.cornerRadius = self.sendButton.frame.size.height / 2.0;
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 4.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("onKeyboardHeightDidChange:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(self.height)
        self.heightChangeStore?(height: self.height)
    }
    
    func onKeyboardHeightDidChange(notification: NSNotification) {
        
        var animationCurve: UIViewAnimationCurve?
        var animationDuration: Double?
        var keyboardEndRect: CGRect?
        
        if let info = notification.userInfo {
            if let animation = info[UIKeyboardAnimationCurveUserInfoKey] as? Int  {
                animationCurve = UIViewAnimationCurve(rawValue: animation)
            }
            
            if let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                animationDuration = duration
            }
            
            if let rect = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardEndRect = rect.CGRectValue()
            }
            
            if keyboardEndRect?.size.height > 0 {
                if keyboardEndRect?.origin.y >= UIApplication.sharedApplication().keyWindow?.frame.size.height {
                    self.bottomConstraint?.updateOffset(0)
                } else {
                    self.bottomConstraint?.updateOffset(-keyboardEndRect!.size.height)
                }
                
                UIView.beginAnimations("TUInputToolbar.keyboard.animations", context: nil)
                UIView.setAnimationDuration(animationDuration!)
                UIView.setAnimationCurve(animationCurve!)
                self.superview?.layoutIfNeeded()
                UIView.commitAnimations()
            }
        }
        
    }
    
    static func create() -> TUInputToolbar {
        let items = NSBundle.mainBundle().loadNibNamed("TUInputToolbar", owner: self, options: nil)
        if let view = items[0] as? TUInputToolbar {
            return view
        }
        return TUInputToolbar()
    }
    
    func showInView(superView: UIView) -> TUInputToolbar {
        superView.addSubview(self)
        self.snp_makeConstraints(closure: {
            [unowned self] (make) -> Void in
            self.bottomConstraint = make.bottom.equalTo(superView.snp_bottom).constraint
            make.left.equalTo(superView.snp_left)
            make.right.equalTo(superView.snp_right)
        })
        return self
    }
    
    func textViewDidChange(textView: UITextView) {
        self.textViewHeightConstraint.constant = min(112, max(36, textView.contentSize.height))
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (fineshed) -> Void in
        }
    }
}
