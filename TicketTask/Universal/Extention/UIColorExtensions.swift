//
//  UIColorExtensions.swift
//  TicketTask
//
//  Created by 999-308 on 2019/12/13.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
extension UIColor {
    static var dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
            return .white
        } else {
            return .black
        }
    }
}
