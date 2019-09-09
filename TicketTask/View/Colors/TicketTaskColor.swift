//
//  GradationColors.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/10.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TicketTaskColor : NSObject {
    
    let BLUE = "blue"
    let ORANGE = "orange"
    let RED = "red"
    let GREEN = "green"
    
    var colors: DictionaryLiteral<String, UIColor>!
    var gradationColors: DictionaryLiteral<String, CGColor> = [:]

    //カラー「blue」
    let ticketTaskBlue_1 = UIColor(red:100/255, green:115/255, blue:255/255, alpha:1)
    let ticketTaskBlue_2 = UIColor(red:72/255, green:168/255, blue:255/255, alpha:1)

    var blueGradientColors: [CGColor]
    
    //カラー「orange」
    let ticketTaskOrange_1 = UIColor(red:238/255, green:133/255, blue:115/255, alpha:1)
    let ticketTaskOrange_2 = UIColor(red:238/255, green:208/255, blue:93/255, alpha:1)

    var orangeGradientColors: [CGColor]
    
    //カラー「red」
    let ticketTaskRed_1 = UIColor(red:234/255, green:77/255, blue:75/255, alpha:1)
    let ticketTaskRed_2 = UIColor(red:214/255, green:137/255, blue:95/255, alpha:1)

    var redGradientColors: [CGColor]
    
    //カラー「green」
    let ticketTaskGreen_1 = UIColor(red:22/255, green:168/255, blue:166/255, alpha:1)
    let ticketTaskGreen_2 = UIColor(red:26/255, green:200/255, blue:140/255, alpha:1)
    
    var greenGradientColors: [CGColor]
    
    override init() {
        self.colors = [BLUE:ticketTaskBlue_1, ORANGE:ticketTaskOrange_1, RED:ticketTaskRed_1, GREEN:ticketTaskGreen_1]
        self.blueGradientColors = [ticketTaskBlue_2.cgColor, ticketTaskBlue_1.cgColor]
        self.orangeGradientColors = [ticketTaskOrange_2.cgColor, ticketTaskOrange_1.cgColor]
        self.redGradientColors = [ticketTaskRed_2.cgColor, ticketTaskRed_1.cgColor]
        self.greenGradientColors = [ticketTaskGreen_2.cgColor, ticketTaskGreen_1.cgColor]
    }
    
    func getGradation(colorStr: String) -> [CGColor] {
        var gradationColor: [CGColor] = []
        switch colorStr {
        case BLUE:
            gradationColor = blueGradientColors
        case RED:
            gradationColor = redGradientColors
        case ORANGE:
            gradationColor = orangeGradientColors
        case GREEN:
            gradationColor = greenGradientColors
        default:
            print("no color")
        }
        return gradationColor
    }
}
