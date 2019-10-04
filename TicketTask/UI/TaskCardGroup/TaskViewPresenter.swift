//
//  TaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/04.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol TaskViewPresenterProtocol {
    
}

class TaskViewPresenter: TaskViewPresenterProtocol {
    
    private var view: TaskViewProtocol!
    
    var mainViewController: MainViewControllerProtocol!
    
    init(view: TaskViewProtocol, mainViewController: MainViewControllerProtocol) {
        self.view = view
        self.mainViewController = mainViewController
    }
}
