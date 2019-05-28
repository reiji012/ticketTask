//
//  GradationColors.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/10.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class GradationColors : NSObject {
    
    //属性「生活」のカラー
    let attriLifeTopColor = UIColor(red:72/255, green:168/255, blue:255/255, alpha:1)
    let attriLifeBottomColor = UIColor(red:100/255, green:115/255, blue:255/255, alpha:1)
    var attriLifeGradientColors: [CGColor]
    
    //属性「b」のカラー
    let attriWorkTopColor = UIColor(red:238/255, green:208/255, blue:93/255, alpha:1)
    let attriWorkBottomColor = UIColor(red:238/255, green:133/255, blue:115/255, alpha:1)
    var attriWorkGradientColors: [CGColor]
    
    //追加画面のカラー
    let addViewTopColor = UIColor(red:26/255, green:188/255, blue:156/255, alpha:1)
    let addViewBottomColor = UIColor(red:26/255, green:188/255, blue:156/255, alpha:1)
    var addViewGradientColors: [CGColor]
    
    override init() {
        self.attriLifeGradientColors = [attriLifeTopColor.cgColor, attriLifeBottomColor.cgColor]
        self.attriWorkGradientColors = [attriWorkTopColor.cgColor, attriWorkBottomColor.cgColor]
        self.addViewGradientColors = [addViewTopColor.cgColor, addViewBottomColor.cgColor]
    }
    
}
