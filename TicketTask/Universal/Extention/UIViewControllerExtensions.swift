//
//  UIViewControllerExtensions.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: UITextFieldDelegate {

    //    @objc private func onKeyboardWillShow(_ notification: Notification) {
    //        guard
    //            let userInfo = notification.userInfo,
    //            let keyboardInfo = UIKeyboardInfo(info: userInfo),
    //            let inputView = view.findFirstResponder(),
    //            let scrollView = inputView.findSuperView(ofType: UIScrollView.self)
    //            else { return }
    //
    //        let inputRect = inputView.convert(inputView.bounds, to: scrollView)
    //        let keyboardRect = scrollView.convert(keyboardInfo.frame, from: nil)
    //        let offsetY = inputRect.maxY - keyboardRect.minY
    //        if offsetY > 0 {
    //            let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + offsetY)
    //            scrollView.contentOffset = contentOffset
    //        }
    //        // 例えば iPhoneX の Portrait 表示だと bottom に34ptほど隙間ができるのでその分を差し引く
    //        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardInfo.frame.height - view.safeAreaInsets.bottom, right: 0)
    //        scrollView.contentInset = contentInset
    //        scrollView.scrollIndicatorInsets = contentInset
    //    }
    //
    //    @objc private func onKeyboardWillHide(_ notification: Notification) {
    //        guard
    //            let inputView = view.findFirstResponder(),
    //            let scrollView = inputView.findSuperView(ofType: UIScrollView.self)
    //            else { return }
    //        scrollView.contentInset = .zero
    //        scrollView.scrollIndicatorInsets = .zero
    //    }

}
