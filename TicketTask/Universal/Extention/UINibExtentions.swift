//
//  UINibExtentions.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/04.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

extension UINib {
    /// UINibのClass名と同じNibファイルを使用してinstaceを作成する。
    /// NibFileのEntryPointが引数のClass名と同じViewControllerに対してのみ使用可能
    ///
    /// - Parameter className: UIViewControllerを継承しているClass名
    /// - Returns: 引数で渡したClass名のViewControllerのinstanceを返す
    public static func instantiateInitialView<T>(from className: T.Type) -> T where T: UIView {
        let name = String(describing: className.self)
        guard let view = UINib(nibName: name, bundle: .main).instantiate(withOwner: self, options: nil).first as? T else {
            fatalError("型が不一致")
        }
        return view
    }
}
