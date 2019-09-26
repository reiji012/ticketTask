//
//  TicketTabbarController.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/27.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
class TicketTabbarController: UITabBarController {
    // MARK: - Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

    }

    // MARK: - Private Function
    // タブ選択時に中のコンテンツをスライドさせるアニメーションを付与する
    private func animateTabContents(_ toIndex: Int) {
        // MEMO: カスタムアニメーションに必要な要素をそれぞれ取得する
        guard let tabViewControllers = self.viewControllers else {
            return
        }
        guard let selectedViewController = self.selectedViewController else {
            return
        }
        guard let fromView = selectedViewController.view else {
            return
        }
        guard let toView = tabViewControllers[toIndex].view else {
            return
        }
        // MEMO: タブ切り替え対象のインデックス値を取得し、遷移先と遷移元のインデックス値が同じの場合は以降の処理は実行しない
        guard let fromIndex = tabViewControllers.lastIndex(of: selectedViewController) else {
            return
        }
        if fromIndex == toIndex {
            return
        }
        // MEMO: 遷移元のViewの親Viewへ遷移先のViewを追加する
        guard let superview = fromView.superview else {
            return
        }
        superview.addSubview(toView)
        
        // MEMO: 左右どちらにスライドするかを決める
        let screenWidth = UIScreen.main.bounds.size.width
        let shouldScrollRight = toIndex > fromIndex
        let offset = (shouldScrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // アニメーション開始直前にUserInteractionを無効にする
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.46, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            // MEMO: 左右どちらかにスライドするアニメーションを付与する
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
            toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)
        }, completion: { finished in
            // 遷移元のViewを削除にしてUserInteractionを有効にする
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
}
// MARK: - UITabBarControllerDelegate
extension TicketTabbarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 移動する先のインデックス値を取得する
        guard let tabViewControllers = tabBarController.viewControllers else {
            return false
        }
        guard let toIndex = tabViewControllers.lastIndex(of: viewController) else {
            return false
        }
        // コンテンツを切り替えるアニメーションを実行する
        animateTabContents(toIndex)
        return true
    }
}
