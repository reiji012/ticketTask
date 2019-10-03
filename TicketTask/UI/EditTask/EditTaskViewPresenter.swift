//
//  EditTaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/03.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol EditTaskViewPresenterProtocol {
    
}

class EditTaskViewPresenter: EditTaskViewPresenterProtocol {
    
    private var view: EditTaskViewControllerProtocol!
    
    init(view: EditTaskViewControllerProtocol) {
        self.view = view
    }
}
