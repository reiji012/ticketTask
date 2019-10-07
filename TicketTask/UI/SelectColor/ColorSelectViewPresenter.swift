//
//  ColorSelectViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol ColorSelectViewPresenterProtocol {
    
}

class ColorSelectViewPresenter: ColorSelectViewPresenterProtocol {
    
    var view: ColorSelectViewControllerProtocol!
    
    init(view: ColorSelectViewControllerProtocol) {
        self.view = view
    }
}
