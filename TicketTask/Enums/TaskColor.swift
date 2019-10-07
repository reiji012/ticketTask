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
    case blue
    case orange
    case red
    case green
    
    var gradationColor1: UIColor {
        switch self {
        case .blue:
            return  UIColor(red:100/255, green:115/255, blue:255/255, alpha:1)
        case .orange:
            return UIColor(red:238/255, green:133/255, blue:115/255, alpha:1)
        case .red:
            return UIColor(red:234/255, green:77/255, blue:75/255, alpha:1)
        case .green:
            return UIColor(red:22/255, green:168/255, blue:166/255, alpha:1)
        }
    }
    
    var gradationColor2: UIColor {
        switch self {
        case .blue:
            return  UIColor(red:100/255, green:115/255, blue:255/255, alpha:1)
        case .orange:
            return UIColor(red:238/255, green:208/255, blue:93/255, alpha:1)
        case .red:
            return UIColor(red:214/255, green:137/255, blue:95/255, alpha:1)
        case .green:
            return UIColor(red:26/255, green:200/255, blue:140/255, alpha:1)
        }
    }
    
    var gradationColor: [CGColor] {
        return [gradationColor1.cgColor, gradationColor2.cgColor]
    }
    
    var colorString: String {
        switch self {
        case .blue:
            return  "blue"
        case .orange:
            return "orange"
        case .red:
            return "red"
        case .green:
            return "green"
        }
    }
}
