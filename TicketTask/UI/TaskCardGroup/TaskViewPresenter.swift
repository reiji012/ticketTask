//
//  TaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/04.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol TaskViewPresenterProtocol {
    var taskViewModel: TaskViewModel { get }
    var menuLeftConst: CGFloat { get }
    var currentColor: TaskColor { get }
    var progressBarWidthConst: CGFloat { get }
    func deleteTask()
    func didTouchAddTicketButton(ticket: String, memo: String)
    func didTouchCheckButtonAsEdit(title: String, memo: String, identifier: String)
    func touchView()
    func content(index: Int) -> (title: String, memo: String, identifier: String)
    func taskDidUpdate()
}

class TaskViewPresenter: TaskViewPresenterProtocol {

    // MARK: - Public Propaty
    var task: TaskModel?
    var taskViewModel: TaskViewModel
    var menuLeftConst: CGFloat
    var progressBarWidthConst: CGFloat
    var currentColor: TaskColor {
        return taskViewModel.taskColor!
    }

    var mainViewController: MainViewControllerProtocol!

    // MARK: - Private Property
    private var view: TaskViewProtocol!

    // MARK: - InitiaLize
    init(view: TaskViewProtocol, mainViewController: MainViewControllerProtocol, task: TaskModel) {
        self.view = view
        self.mainViewController = mainViewController
        self.task = task

        let taskName = task.taskTitle
        // taskViewModelの取得
        taskViewModel = TaskViewModel(taskName: taskName)
        taskViewModel.countProgress()
        taskViewModel.getTask(taskName: taskName)
        taskViewModel.delegate = mainViewController

        // 端末サイズによってメニュー、プログレスバーの長さを調整
        switch screenType {
        case .iPhone3_5inch, .iPhone4_0inch:
            menuLeftConst = 107.0
            progressBarWidthConst = 170
        case .iPhone4_7inch, .iPhone5_8inch:
            menuLeftConst = 147.0
            progressBarWidthConst = 210
        case .iPhone5_5inch, .iPhone6_1inch, .iPhone6_5inch:
            menuLeftConst = 185
            progressBarWidthConst = 235
        default:
            menuLeftConst = 107.0
            progressBarWidthConst = 170
        }
    }

    // MARK: - Public Function
    /// タスク削除
    func deleteTask() {
        guard let view = self.view as? TaskView else {
            return
        }

        taskViewModel.updateModel(actionType: .taskDelete, callback: {
            self.mainViewController.deleteTask(view: view)
        })
    }

    /// チケットの追加
    ///
    /// - Parameter ticket: 追加するチケット
    func didTouchAddTicketButton(ticket: String, memo: String) {
        taskViewModel.actionType = .ticketCreate
        taskViewModel.addTicket(ticketName: ticket, memo: memo, callback: {
            self.view.didCreatedTicketd()
        })
    }

    func didTouchCheckButtonAsEdit(title: String, memo: String, identifier: String) {
        taskViewModel.editTicket(ticketName: title, memo: memo, identifier: identifier, callback: {
            self.view.didCreatedTicketd()
        })
    }

    func content(index: Int) -> (title: String, memo: String, identifier: String) {
        let title = taskViewModel.tickets![index].ticketName
        let memo = taskViewModel.tickets![index].comment
        let identifier = taskViewModel.tickets![index].identifier
        return (title: title, memo: memo, identifier: identifier)
    }

    func touchView() {
        guard let view = view as? TaskView else {
            return
        }
        view.changeViewSize()
    }

    func taskDidUpdate() {
        taskViewModel.getTaskData()
        taskViewModel.countProgress()
        view.reloadDate()
    }
}
