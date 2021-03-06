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
    var taskViewModel: TaskViewModel? { get }
    var currentColor: TaskColor { get set }
    var currentIconString: String { get set }
    var currentIcon: UIImage { get }
    var currentResetType: Int { get }
    var taskView: TaskViewProtocol! { get }
    func numberOfRow() -> Int
    func contents(index: Int) -> (date: Date, isActive: Bool, identifier: String)
    func viewDidLoad()
    func touchSaveButton(afterTaskName: String)
    func touchTimerSetButton(resetTypeIndex: Int)
    func didDoneDatePicker(selectDate: Date)
    func didChengeNotificationActive(isActive: Bool, identifier: String)
    func didDeleteNotification(index: Int)
}

class EditTaskViewPresenter: EditTaskViewPresenterProtocol, ErrorAlert {

    // MARK: - Public Propaty
    var taskView: TaskViewProtocol!
    var taskViewModel: TaskViewModel?
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

    // MARK: - Private Property
    private var view: EditTaskViewControllerProtocol!
    private var taskLocalDataModel: TaskLocalDataModel = TaskLocalDataModel.sharedManager
    private var beforeName: String?
    private var resetTypeIndex: Int?
    private let currentTaskModel: TaskModel

    // 削除した通知のidentifierを保持しておく
    private var deleteNotificationsIdentifier: [String] = []

    // MARK: - initialize
    init(view: EditTaskViewControllerProtocol, taskView: TaskViewProtocol) {
        self.view = view
        self.taskView = taskView
        taskViewModel = taskView.presenter.taskViewModel
        currentColor = taskViewModel!.taskColor!
        currentIcon = taskViewModel!.iconImage!
        beforeName = taskViewModel!.taskName!
        currentTaskModel = TaskModel(id: taskViewModel!.taskID!)
        currentTaskModel.resetType = taskViewModel!.resetTypeIndex!
        currentTaskModel.notifications = (taskViewModel?.notifications!)!
        currentTaskModel.color = taskViewModel!.taskColor!.colorString
    }

    /// セルの数を返す
    func numberOfRow() -> Int {
        return currentTaskModel.notifications.isEmpty ? 0 : currentTaskModel.notifications.count
    }

    /// セルの中身を返す
    func contents(index: Int) -> (date: Date, isActive: Bool, identifier: String) {
        let notice = currentTaskModel.notifications[index]
        return (notice.date!, notice.isActive!, notice.identifier)
    }

    // MARK: - Public Function
    func viewDidLoad() {
        view.setTimeSelectIndex(index: currentTaskModel.resetType)
        currentIconString = taskViewModel!.iconString!
        view.configureNavigationBar()
        view.configureBind()
        view.cunfigureDelegate()
        view.initSetViewState()
    }

    // 保存ボタン
    func touchSaveButton(afterTaskName: String) {

        if afterTaskName.isEmpty {
            guard let viewController = self.view as? EditTaskViewController else {
                return
            }
            createErrorAlert(error: .titleEmptyError, massage: nil, view: viewController)
            view.resetTitle(title: beforeName!)
            return
        }
        currentTaskModel.taskTitle = afterTaskName
        currentTaskModel.attri = ""

        let error = taskLocalDataModel.editTask(currentTaskModel: currentTaskModel, beforeName: beforeName!, deleteNotifications: deleteNotificationsIdentifier, completion: {
            let vm = self.taskView.presenter.taskViewModel
            vm.taskName = afterTaskName
            vm.attri = ""
            vm.taskColor = currentColor
            vm.iconImage = currentIcon
            vm.iconString = currentIconString
            vm.resetTypeIndex = currentResetType
            vm.notifications = currentTaskModel.notifications
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

    // 通知削除
    func didDeleteNotification(index: Int) {
        let noticeIdentifier = currentTaskModel.notifications[index].identifier
        deleteNotificationsIdentifier.append(noticeIdentifier)
        currentTaskModel.notifications.remove(at: index)
    }

    func didDoneDatePicker(selectDate: Date) {
        let dateString = Util.stringFromDateAsNotice(date: selectDate)
        createTaskNotification(id: currentTaskModel.notifications.count + 1, dateString: dateString)
        view.reloadNotificationTable()
    }

    // 通知がオン・オフで切り替わった時
    func didChengeNotificationActive(isActive: Bool, identifier: String) {
        let notice = currentTaskModel.notifications.filter { $0.identifier == identifier }.first!
        let index = currentTaskModel.notifications.index(of: notice)
        currentTaskModel.notifications[index!].isActive = isActive
    }

    private func createTaskNotification(id: Int, dateString: String) {
        let notice = TaskNotificationsModel()
        notice.date = Util.dateFromStringAsNotice(string: dateString)
        notice.id = id
        notice.isActive = true
        notice.identifier = NSUUID().uuidString
        currentTaskModel.notifications.append(notice)
    }
}
