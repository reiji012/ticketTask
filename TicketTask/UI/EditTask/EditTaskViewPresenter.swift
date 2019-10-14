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
    var currentResetType: Int { get }
    func viewDidLoad()
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
    private let taskViewModel: TaskViewModel?
    
    var currentIconString: String = "" {
        didSet {
            currentTaskModel.icon = currentIconString
            currentIcon = (UIImage(named: currentIconString)?.withRenderingMode(.alwaysTemplate))!
            view.setIconImage(icon: currentIcon)
        }
    }
    var currentResetType: Int {
        return currentTaskModel.resetType
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
        taskViewModel = taskView.presenter.taskViewModel
        currentColor = taskViewModel!.taskColor!
        currentIcon = taskViewModel!.iconImage!
        currentIconString = taskViewModel!.iconString!
        beforeName = taskViewModel!.taskName!
        currentTaskModel = TaskModel(id: taskViewModel!.taskID!)
        currentTaskModel.resetType = taskViewModel!.resetTypeIndex!
    }
    
    func viewDidLoad() {
        view.setTimeSelectIndex(index: currentTaskModel.resetType)
        view.setNavigationBar()
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
