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
    func touchTimerSetButton(resetTypeIndex: Int)
}

class EditTaskViewPresenter: EditTaskViewPresenterProtocol, ErrorAlert {
    
    
    private var view: EditTaskViewControllerProtocol!
    private var taskView: TaskViewProtocol!
    private var taskLocalDataModel: TaskLocalDataModel = TaskLocalDataModel.sharedManager
    private var beforeName: String?
    private var resetTypeIndex: Int?
    private let currentTaskModel: TaskModel
    
    var currentIconString: String = "" {
        didSet {
            currentTaskModel.icon = currentIconString
            currentIcon = (UIImage(named: currentIconString)?.withRenderingMode(.alwaysTemplate))!
            view.setIconImage(icon: currentIcon)
        }
    }
    
    var currentIcon: UIImage
    var currentColor: TaskColor {
        didSet {
            currentTaskModel.color = currentColor.colorString
            view.setColorView(color: currentColor.gradationColor1)
        }
    }
//    var currentResetTypeIndex: Int
    
    init(view: EditTaskViewControllerProtocol, taskView: TaskViewProtocol) {
        self.view = view
        self.taskView = taskView
        currentColor = taskView.presenter.taskViewModel.taskColor!
        currentIcon = taskView.presenter.taskViewModel.iconImage!
        currentIconString = taskView.presenter.taskViewModel.iconString!
        beforeName = taskView.presenter.taskViewModel.taskName!
        currentTaskModel = TaskModel(id: taskView.presenter.taskViewModel.taskID!)
    }
    
    func touchSaveButton(afterTaskName: String) {
        let currentTaskModel = TaskModel(id: taskView.presenter.taskViewModel.taskID!)
        currentTaskModel.taskTitle = afterTaskName
        currentTaskModel.attri = ""
        
        let error = taskLocalDataModel.editTask(currentTaskModel: currentTaskModel, beforeName: beforeName!, completion: {
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
    
    func touchTimerSetButton(resetTypeIndex: Int) {
        currentTaskModel.resetType = resetTypeIndex
    }
}
