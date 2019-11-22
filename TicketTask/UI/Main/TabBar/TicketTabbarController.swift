//
//  TicketTabbarController.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/27.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import ESTabBarController_swift

protocol TicketTabbarControllerProtocol {
    func configureViewControllers()
}

class TicketTabbarController: ESTabBarController, TicketTabbarControllerProtocol {
    
    var presenter: TicketTabbarViewPresenterProtocol!
    
    // MARK: - Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        self.presenter = TicketTabbarViewPresenter(view: self)
        presenter.viewDidLoad()
    }
    
    func configureViewControllers() {
        let mainViewController = MainViewController.initiate()
        let settingViewController = SettingViewController.initiate()
        let historyViewController = HistoryViewController.initiate()
        
        self.viewControllers = [mainViewController, historyViewController, settingViewController]
        selectedIndex = 0
    }

    // MARK: - Private Function

}
// MARK: - UITabBarControllerDelegate
extension TicketTabbarController: UITabBarControllerDelegate {
}
