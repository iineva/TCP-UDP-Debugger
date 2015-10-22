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
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    var bottomConstraint: Constraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendButton.layer.cornerRadius = self.sendButton.frame.size.height / 2.0;
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 4.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("onKeyboardHeightDidChange:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
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
    
    private static func toolbar() -> TUInputToolbar? {
        let items = NSBundle.mainBundle().loadNibNamed("TUInputToolbar", owner: self, options: nil)
        if let view = items[0] as? TUInputToolbar {
            return view
        }
        return nil
    }
    
    class func showInView(superView: UIView) {
        let toolbar = TUInputToolbar.toolbar()
        if let tool = toolbar {
            superView.addSubview(tool)
            tool.snp_makeConstraints(closure: {
                [unowned tool] (make) -> Void in
                tool.bottomConstraint = make.bottom.equalTo(superView.snp_bottom).constraint
                make.left.equalTo(superView.snp_left)
                make.right.equalTo(superView.snp_right)
            })
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.textViewHeightConstraint.constant = min(112, max(36, textView.contentSize.height))
        UIView.animateWithDuration(0.3) { () -> Void in
            self.layoutIfNeeded()
        }
    }
}
