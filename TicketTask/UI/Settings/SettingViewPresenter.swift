//
//  SettingViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/22.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol SettingViewPresenterProtocol {
    func viewDidLoad()
}

class SettingViewPresenter: SettingViewPresenterProtocol {

    private var view: SettingViewControllerProtocol

    init(view: SettingViewControllerProtocol) {
        self.view = view
    }

    func viewDidLoad() {

    }
}
