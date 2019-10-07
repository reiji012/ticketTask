//
//  ColorSelectViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol ColorSelectViewPresenterProtocol {
    func selectContent(indexPath: IndexPath) -> TaskColor 
}

class ColorSelectViewPresenter: ColorSelectViewPresenterProtocol {
    
    var view: ColorSelectViewControllerProtocol!
    
    init(view: ColorSelectViewControllerProtocol) {
        self.view = view
    }
    
    func selectContent(indexPath: IndexPath) -> TaskColor {
        switch indexPath.row {
        case 0:
            return .blue
        case 1:
            return .orange
        case 2:
            return .red
        case 3:
            return .green
        default:
            return .orange
        }
    }
}
