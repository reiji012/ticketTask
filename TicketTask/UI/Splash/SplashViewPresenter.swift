//
//  SplashViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/29.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol SplashViewPresenterProtocol {
    func viewDidAppear()
}

class SplashViewPresente: SplashViewPresenterProtocol, Routable {
    private var view: SplashViewControllerProtocol

    init(view: SplashViewControllerProtocol) {
        self.view = view
    }

    func viewDidAppear() {
        guard let viewController = view as? SplashViewController else {
            return
        }
        present(.mainViewController, from: viewController, animated: false)
    }
}
