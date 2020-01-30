//
//  SettingViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/22.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol HistoryViewPresenterProtocol {
    func viewDidLoad()
}

class HistoryViewPresenter: HistoryViewPresenterProtocol {

    private var view: HistoryViewControllerProtocol

    init(view: HistoryViewControllerProtocol) {
        self.view = view
    }

    func viewDidLoad() {

    }
}
