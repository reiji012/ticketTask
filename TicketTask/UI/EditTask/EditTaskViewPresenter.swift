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
    var currentColor: TaskColor { get set }
    var currentIconString: String { get set }
    var currentIcon: UIImage { get }
    func touchSaveButton(afterTaskName: String)
}

class EditTaskViewPresenter: EditTaskViewPresenterProtocol, ErrorAlert {
    
    
    private var view: EditTaskViewControllerProtocol!
    private var taskView: TaskViewProtocol!
    private var taskModel: TaskModel = TaskModel.sharedManager
    private var beforeName: String?
    
    var currentIconString: String = "" {
        didSet {
            currentIcon = (UIImage(named: currentIconString)?.withRenderingMode(.alwaysTemplate))!
            view.setIconImage(icon: currentIcon)
        }
    }
    
    var currentIcon: UIImage
    var currentColor: TaskColor {
        didSet {
            view.setColorView(color: currentColor.gradationColor1)
        }
    }
    
    init(view: EditTaskViewControllerProtocol, taskView: TaskViewProtocol) {
        self.view = view
        self.taskView = taskView
        currentColor = taskView.presenter.taskViewModel.taskColor!
        currentIcon = taskView.presenter.taskViewModel.iconImage!
        currentIconString = taskView.presenter.taskViewModel.iconString!
        beforeName = taskView.presenter.taskViewModel.taskName!
    }
    
    func touchSaveButton(afterTaskName: String) {
        let error = taskModel.editTask(afterTaskName: afterTaskName, afterTaskAttr: "", colorStr: currentColor.colorString, imageStr: currentIconString, id: taskView.presenter.taskViewModel.taskID!, beforeName: beforeName!, completion: {
            let vm = self.taskView.presenter.taskViewModel
            vm.taskName = afterTaskName
            vm.attri = ""
            vm.taskColor = currentColor
            vm.iconImage = currentIcon
            vm.iconString = currentIconString
            view.didSaveTask()
        })
        if let error = error {
            guard let viewController = self.view as? EditTaskViewController else {
                return
            }
            createErrorAlert(error: error, massage: "", view: viewController)
        }
    }
}
