//
//  EditTaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/03.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol EditTaskViewPresenterProtocol {
    func touchSaveButton(afterTaskName: String, afterTaskAttr: String, color: UIColor, colorStr: String, image: UIImage, imageStr: String)
}

class EditTaskViewPresenter: EditTaskViewPresenterProtocol {
    
    private var view: EditTaskViewControllerProtocol!
    private var taskView: TaskView!
    
    init(view: EditTaskViewControllerProtocol, taskView: TaskView) {
        self.view = view
        self.taskView = taskView
    }
    
    func touchSaveButton(afterTaskName: String, afterTaskAttr: String, color: UIColor, colorStr: String, image: UIImage, imageStr: String) {
        
    }
}
