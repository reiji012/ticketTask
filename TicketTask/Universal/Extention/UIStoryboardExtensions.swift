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

    /// UIViewControllerのClass名と同じStoryboardを使用してidentifierが一致するものからinstaceを作成する。
    /// StoryboardのEntryPoint関係なく引数のClass名と同じまたは指定したidentifierがある時のみ使用可能
    ///
    /// - Parameters:
    ///   - className: UIViewControllerを継承しているClass名
    ///   - identifier: Storyboard identifier 省略した場合、class名と一致するものを探す
    /// - Returns: 引数で渡したClass名のViewControllerのinstanceを返す
    public static func instantiateViewController<T>(from className: T.Type, identifier: String? = nil) -> T where T : UIViewController {
        let name = String(describing: className.self)
        let identifier = identifier ?? name
        guard let viewController = UIStoryboard(name: name, bundle: .main).instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("型が不一致または該当するStoryboardが存在しない")
        }
        return viewController
    }

    /// UIViewControllerのClass名と同じStoryboardを使用してinstaceを作成する。
    /// StoryboardのEntryPointがUINavigationControllerに対してのみ使用可能
    ///
    /// - Parameter className: UIViewControllerを継承しているClass名
    /// - Returns: UINavigationControllerを返す
    public static func instanceNavigationController<T>(from className: T.Type) -> UINavigationController {
        let name = String(describing: className.self)
        guard let viewController = UIStoryboard(name: name, bundle: .main).instantiateInitialViewController() as? UINavigationController else {
            fatalError("型が不一致")
        }
        return viewController
    }
}
