//
//  File.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

enum TaskColor {
    case dark
    case blue
    case orange
    case red
    case green
    case purple
    case yello

    var gradationColor1: UIColor {
        switch self {
        case .dark:
            return  UIColor(red: 13/255, green: 16/255, blue: 60/255, alpha: 1)
        case .blue:
            return  UIColor(red: 100/255, green: 115/255, blue: 255/255, alpha: 1)
        case .orange:
            return UIColor(red: 238/255, green: 133/255, blue: 115/255, alpha: 1)
        case .red:
            return UIColor(red: 234/255, green: 77/255, blue: 75/255, alpha: 1)
        case .green:
            return UIColor(red: 22/255, green: 168/255, blue: 166/255, alpha: 1)
        case .purple:
            return UIColor(red: 74/255, green: 16/255, blue: 102/255, alpha: 1)
        case .yello:
            return UIColor(red: 255/255, green: 231/255, blue: 0/255, alpha: 1)
        }
    }

    var gradationColor2: UIColor {
        switch self {
        case .dark:
            return  UIColor(red: 12/255, green: 56/255, blue: 149/255, alpha: 1)
        case .blue:
            return  UIColor(red: 72/255, green: 168/255, blue: 255/255, alpha: 1)
        case .orange:
            return UIColor(red: 238/255, green: 208/255, blue: 93/255, alpha: 1)
        case .red:
            return UIColor(red: 229/255, green: 151/255, blue: 142/255, alpha: 1)
        case .green:
            return UIColor(red: 26/255, green: 200/255, blue: 140/255, alpha: 1)
        case .purple:
            return UIColor(red: 166/255, green: 126/255, blue: 192/255, alpha: 1)
        case .yello:
            return UIColor(red: 255/255, green: 230/255, blue: 80/255, alpha: 1)
        }
    }

    var gradationColor: [CGColor] {
        return [gradationColor2.cgColor, gradationColor1.cgColor]
    }

    var colorString: String {
        switch self {
        case .dark:
            return "dark"
        case .blue:
            return  "blue"
        case .orange:
            return "orange"
        case .red:
            return "red"
        case .green:
            return "green"
        case .purple:
            return "purple"
        case .yello:
            return "yello"
        }
    }
}
