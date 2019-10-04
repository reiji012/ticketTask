//
//  TaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/04.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol TaskViewPresenterProtocol {
    var taskViewModel: TaskViewModel { get }
}

class TaskViewPresenter: TaskViewPresenterProtocol {
    
    private var view: TaskViewProtocol!

    var task: Dictionary<String, Any>?
    var taskViewModel: TaskViewModel
    
    var mainViewController: MainViewControllerProtocol!
    
    init(view: TaskViewProtocol, mainViewController: MainViewControllerProtocol, task: Dictionary<String, Any>) {
        self.view = view
        self.mainViewController = mainViewController
        self.task = task
        
        let taskName = (task["title"] as! String)
        // taskViewModelの取得
        taskViewModel = TaskViewModel(taskName: taskName)
        taskViewModel.countProgress()
        taskViewModel.getTask(taskName: taskName)
    }
}
