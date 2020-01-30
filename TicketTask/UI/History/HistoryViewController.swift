//
//  SettingViewController.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/22.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

protocol HistoryViewControllerProtocol {

}

class HistoryViewController: UIViewController, HistoryViewControllerProtocol {

    private var presenter: HistoryViewPresenterProtocol!

    // MARK: - Initilizer
    static func initiate() -> HistoryViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = HistoryViewPresenter(view: viewController)
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
