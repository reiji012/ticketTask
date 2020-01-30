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

    func convertDarkColorAsUnder() -> UIColor {

        let components = self.cgColor.components! // UIColorをCGColorに変換し、RGBとAlphaがそれぞれCGFloatで配列として取得できる
        return UIColor(red: components[0] * 0.13, green: components[1] * 0.14, blue: components[2] * 0.23, alpha: components[3])
    }

    func convertDarkColorAsTop() -> UIColor {

        let components = self.cgColor.components! // UIColorをCGColorに変換し、RGBとAlphaがそれぞれCGFloatで配列として取得できる
        return UIColor(red: components[0] * 0.16, green: components[1] * 0.33, blue: components[2] * 0.58, alpha: components[3])
    }
}

extension UITraitCollection {

    public static var isDarkMode: Bool {
        if #available(iOS 13, *), current.userInterfaceStyle == .dark {
            return true
        }
        return false
    }

}
