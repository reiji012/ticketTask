//
//  ScreenType.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/01.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

let screenType = ScreenType()

enum ScreenType {
    case iPhone3_5inch
    case iPhone4_0inch
    case iPhone4_7inch
    case iPhone5_5inch
    case iPhone5_8inch
    case iPhone6_1inch
    case iPhone6_5inch
    case other
    
    var taskViewCardWidth: CGFloat {
        switch self {
        case .iPhone3_5inch:
            return 256
        case .iPhone4_0inch:
            return 256
        case .iPhone4_7inch:
            return 311
        case .iPhone5_5inch:
            return 350
        case .iPhone5_8inch:
            return 311
        case .iPhone6_1inch:
            return 350
        case .iPhone6_5inch:
            return 350
        case .other:
            return 311
        }
    }
    
    init() {
        let screenSize = UIScreen.main.bounds.size
        
        switch screenSize {
        case CGSize(width: 320.0, height: 480.0):
            self = .iPhone3_5inch
        case CGSize(width: 320.0, height: 568.0):
            self = .iPhone4_0inch
        case CGSize(width: 375.0, height: 667.0):
            self = .iPhone4_7inch
        case CGSize(width: 414.0, height: 736.0):
            self = .iPhone5_5inch
        case CGSize(width: 375.0, height: 812.0):
            self = .iPhone5_8inch
        case CGSize(width: 414.0, height: 896.0):
            self = .iPhone6_1inch
        case CGSize(width: 414.0, height: 896.0):
            self = .iPhone6_5inch
        default:
            self = .other
        }
    }
}
