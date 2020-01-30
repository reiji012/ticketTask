//
//  TicketTabbarViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/22.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol TicketTabbarViewPresenterProtocol {
    func viewDidLoad()
}

class TicketTabbarViewPresenter: TicketTabbarViewPresenterProtocol {
    var view: TicketTabbarControllerProtocol

    init(view: TicketTabbarControllerProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        view.configureViewControllers()
    }
}
