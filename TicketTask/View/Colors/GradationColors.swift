//
//  GradationColors.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/10.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class GradationColors : NSObject {
    
    //属性「a」のカラー
    let attriATopColor = UIColor(red:0.47, green:0.73, blue:0.96, alpha:1)
    let attriABottomColor = UIColor(red:0.34, green:0.54, blue:0.94, alpha:1)
    var attriAGradientColors: [CGColor]
    //属性「b」のカラー
    let attriBTopColor = UIColor(red:238/255, green:208/255, blue:93/255, alpha:1)
    let attriBBottomColor = UIColor(red:238/255, green:133/255, blue:115/255, alpha:1)
    var attriBGradientColors: [CGColor]
    
    override init() {
        self.attriAGradientColors = [attriATopColor.cgColor, attriABottomColor.cgColor]
        self.attriBGradientColors = [attriBTopColor.cgColor, attriBBottomColor.cgColor]
    }
    
}
