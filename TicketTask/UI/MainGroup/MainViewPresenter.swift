//
//  MainViewModel.swift
//  TicketTask
//
//  Created by 999-308 on 2019/09/30.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol MainViewPresenterProtocol {
    var tasks: [TaskModel] { get }
    var taskTotalCount: Int { get }
    var completedTasks: [TaskModel] { get }
    var uncompletedTasks: [TaskModel] { get }
    var contents: [TaskViewContentValue] { get set }
    var currentColor: TaskColor { get set }
    func getTaskModel(title: String) -> TaskModel?
    func viewDidLoad()
    func touchAddButton()
    func checkIsTaskEmpty()
    func isLastTaskView(view: TaskView) -> Bool
    func didChangedTaskProgress()
    func catchError(error: ValidateError)
}

class MainViewPresenter: MainViewPresenterProtocol, Routable, ErrorAlert {
    
    // MARK: - Public Propaty
    var view: MainViewControllerProtocol!
    var tasks: [TaskModel] {
        return taskLocalDataModel!.tasks
    }
    var taskTotalCount: Int {
        return taskLocalDataModel!.tasks.count
    }
    
    var completedTasks: [TaskModel] = []
    var uncompletedTasks: [TaskModel] = []
    var contents: [TaskViewContentValue] = []
    var currentColor: TaskColor = .orange
    
    // MARK: - Private Property
    private var taskLocalDataModel: TaskLocalDataModel!
    
    // MARK: - Initialize
    init(vc: MainViewControllerProtocol) {
        view = vc
        taskLocalDataModel = TaskLocalDataModel.sharedManager
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        view.configureAddTicketView()
        view.configureProgressRing()
        didChangedTaskProgress()
    }
    
    // MARK: - Public Fuction
    func touchAddButton() {
        guard let viewController = view as? MainViewController else {
            return
        }
        present(.addTaskViewController, from: viewController, animated: true)
    }
    
    // 完了済
    func didTouchCompletedButton() {
        
    }
    
    // 未完了
    func didTouchUnompletedButton() {
        
    }
    
    func getTaskModel(title: String) -> TaskModel? {
        return tasks.filter { $0.taskTitle == title }.first
    }
    
    func checkIsTaskEmpty() {
        let isTaskEmpty = self.taskLocalDataModel!.tasks.isEmpty
        self.view?.setTaskEmptyViewState(isHidden: !(isTaskEmpty))
        if !(isTaskEmpty) {
            self.view?.createAllTaskViews()
        }
    }
    
    /// 最後尾のViewかどうか
    ///
    /// - Parameter view: 確認したいView
    /// - Returns: Bool
    func isLastTaskView(view: TaskView) -> Bool {
        //どこのタブを表示させたいか計算します
        let taskCount: Int = taskTotalCount
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * 400
        if (maxScrollPoint < Int(self.view.stopPoint)) {
            return true
        } else {
            return false
        }
    }
    
    func didChangedTaskProgress() {
        var _completedTasks = [TaskModel]()
        var _uncompletedTasks = [TaskModel]()
        var compTaskCount = 0
        var unCompTaskCount = 0
        for task in tasks {
            if task.tickets.filter({$0.isCompleted != true}).count > 0 {
                unCompTaskCount += 1
                _uncompletedTasks.append(task)
            } else {
                compTaskCount += 1
                _completedTasks.append(task)
            }
        }
        self.completedTasks = _completedTasks
        self.uncompletedTasks = _uncompletedTasks
        let num = tasks.count == 0 ? 0 : (Double(compTaskCount)/Double(tasks.count)*100)
        view.setCircleProgressValue(achievement: CGFloat(num), compCount: compTaskCount, unCompCount: unCompTaskCount)
    }
    
    func catchError(error: ValidateError) {
        guard let viewController = view as? MainViewController else {
            return
        }
        createErrorAlert(error: error, massage: "", view: viewController)
    }
}
