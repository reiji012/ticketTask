//
//  UIStoryboardExtensions.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/03.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

extension UIStoryboard {
    /// UIViewControllerのClass名と同じStoryboardを使用してinstaceを作成する。
    /// StoryboardのEntryPointが引数のClass名と同じViewControllerに対してのみ使用可能
    ///
    /// - Parameter className: UIViewControllerを継承しているClass名
    /// - Returns: 引数で渡したClass名のViewControllerのinstanceを返す
    public static func instantiateInitialViewController<T>(from className: T.Type) -> T where T : UIViewController {
        let name = String(describing: className.self)
        guard let viewController = UIStoryboard(name: name, bundle: .main).instantiateInitialViewController() as? T else {
            fatalError("型が不一致")
        }
        return viewController
    }

}
