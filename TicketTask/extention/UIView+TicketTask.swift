//
//  UIView+TicketTask.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/08.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

struct UIKeyboardInfo {
    let frame: CGRect
    let animationDuration: TimeInterval
    let animationCurve: UIView.AnimationOptions
    
    init?(info: [AnyHashable : Any]) {
        guard
            let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return nil }
        self.frame = frame
        animationDuration = duration
        animationCurve = UIView.AnimationOptions(rawValue: curve)
    }
}

extension UIView{

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for v in subviews {
            if let responder = v.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
    
    func findSuperView<T>(ofType: T.Type) -> T? {
        if let superView = self.superview {
            switch superView {
            case let superView as T:
                return superView
            default:
                return superView.findSuperView(ofType: ofType)
            }
        }
        return nil
    }

}
