//
//  TaskLocalDataModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RealmSwift

enum ResetType {
    case day
    case week
    case month
}

class TaskLocalDataModel {

    let taskList = List<TaskItem>()
    let TASK_TITLE = "taskTitle"
    let TASK_ATTRI = "attri"
    let TASK_TICKETS = "tickets"
    let TASK_ICON = "icon"
    let TASK_COLOR = "color"
    let TASK_CATEGORY = "category"
    let TASK_LASTRESETDATE = "lastResetDate"
    let TASK_RESET_TYPE = "resetType"
    let TICKET_NAME = "ticketName"
    let TICKET_IS_COMPLETED = "isCompleted"
    let settingData = SettingData()

    var tasks: [TaskModel] = []
    var lastCreateTask: TaskModel?

    var realm: Realm!

    static var sharedManager: TaskLocalDataModel = {
        return TaskLocalDataModel()
    }()

    private init() {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        self.realm = try! Realm(configuration: config)

        //        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        let results = realm.objects(TaskItem.self).sorted(byKeyPath: "id", ascending: true)
        if  results.count == 0 {
            print(results)
            //                self.dataFirstInit()
        }
        print(results)

        //データを取り出してモデルに反映する
        for task in results {
            let taskModel = TaskModel(id: task.id)
            taskModel.taskTitle = task.taskTitle
            taskModel.color = task.color
            taskModel.icon = task.icon
            taskModel.category = task.category
            taskModel.lastResetDate = task.lastResetDate
            taskModel.tickets = []
            var _tickets: [TicketsModel] = []
            var _notifications: [TaskNotificationsModel] = []
            let tickets = task.tickets
            for ticket in tickets {
                let _ticket = TicketsModel()
                _ticket.ticketName = ticket.ticketName
                _ticket.isCompleted = ticket.isCompleted
                _ticket.comment = ticket.comment
                _ticket.identifier = ticket.identifier
                _tickets.append(_ticket)
            }
            let notifications = task.taskNotifications
            for noticeTime in notifications {
                let _notice = TaskNotificationsModel()
                _notice.id = noticeTime.id
                _notice.identifier = noticeTime.identifier
                _notice.date = noticeTime.date
                _notice.isActive = noticeTime.isActive
                _notifications.append(_notice)
            }
            taskModel.tickets = _tickets
            taskModel.notifications = _notifications
            taskModel.resetType = task.resetType
            self.tasks.append(taskModel)
        }
    }

    /*タスクを取得する*/
    func getTask(taskName: String) -> TaskModel? {
        var currentTask: TaskModel?
        for task in tasks {
            if task.taskTitle == taskName {
                currentTask = task
            }
        }
        return currentTask
    }

    /*タスクを作成する*/
    func createTask(taskModel: TaskModel) -> ValidateError? {

        if taskModel.taskTitle.isEmpty || taskModel.tickets.count == 0 {
            let error: ValidateError = .inputValidError
            return error
        }

        let results = realm.objects(TaskItem.self)
        let lastID = self.lastId()
        let tasks = results.map {$0.taskTitle}
        if tasks.index(of: taskModel.taskTitle) != nil {
            // 同じ名前のタスクが存在した場合はエラーを返す
            let error = ValidateError.taskValidError
            return error
        }

        // Realm用チケットモデル作成
        let ticketsRealmArray = List<TicketModel>()
        for ticket in taskModel.tickets {
            let ticketRealmModel = TicketModel()
            ticketRealmModel.identifier = ticket.identifier
            ticketRealmModel.ticketName = ticket.ticketName
            ticketRealmModel.isCompleted = false
            ticketsRealmArray.append(ticketRealmModel)
        }
        // Realm用通知設定モデル作成
        let notificationsRealmArray = List<TaskNotifications>()
        for notification in taskModel.notifications {
            let notificationRealmModel = TaskNotifications()
            notificationRealmModel.id = notification.id
            notificationRealmModel.identifier = notification.identifier
            notificationRealmModel.isActive = notification.isActive!
            notificationRealmModel.date = notification.date
            notificationsRealmArray.append(notificationRealmModel)
            // push通知設定
            Notifications().pushNotificationSet(resetTimeType: taskModel.resetType, taskID: lastID, taskTitle: taskModel.taskTitle, notificationModel: notification)
        }

        // テンプレートから時刻を表示
        //        let f = DateFormatter()
        //        f.setTemplate(.date)
        //        let currentDay = f.string(from: Date())
        //        let day = f.date(from: currentDay)

        // Realm用タスクモデル作成
        let taskItem = TaskItem()
        taskItem.id = lastID
        taskItem.taskTitle = taskModel.taskTitle
        taskItem.attri = taskModel.attri
        taskItem.color = taskModel.color
        taskItem.icon = taskModel.icon
        taskItem.tickets = ticketsRealmArray
        taskItem.lastResetDate = Date()
        taskItem.resetType = taskModel.resetType
        taskItem.taskNotifications = notificationsRealmArray

        try! realm.write {
            realm.add(taskItem)
            print("データベース追加後", results.count)
            print(results)
        }

        // タスク追加に成功した時にtasksパラメータにタスクを追加
        self.tasks.append(taskModel)
        self.lastCreateTask = taskModel
        return nil

    }

    /*タスクの更新*/
    func taskUpdate(id: Int, tickets: [TicketsModel], actionType: ActionType, callback: (() -> Void)? = nil) {
        var indexPath = 0
        for (index, task) in self.tasks.enumerated() {
            if task.id == id {
                task.tickets = tickets
                indexPath = index
            }
        }
        // アクションによって処理を変える
        switch actionType {
        case .taskDelete:
            // タスク削除
            self.deleteTask(index: indexPath, callback: {
                if let callback = callback {
                    callback()
                }
            })
        case .ticketUpdate:
            // チケット更新
            self.updateTicket(index: indexPath)
        case .ticketDelete:
            // チケット削除
            self.deleteTicket(index: indexPath, callback: {
                if let callback = callback {
                    callback()
                }
            })
        case .ticketCreate:
            // チケット作成
            self.addTicket(tickets: tickets, id: id)
        default:
            return
        }
    }

    /*チケットの追加*/
    func addTicket(tickets: [TicketsModel], id: Int) {
        guard let task = realm.objects(TaskItem.self).filter("id = \(id)").first else {
            return
        }
        let ticketArray: [String] = task.tickets.map { $0.ticketName }
        let currentTicketArray: [String] = tickets.map { $0.ticketName }
        for (index, ticket) in currentTicketArray.enumerated() {
            if ticketArray.index(of: ticket) == nil {
                try! realm.write {
                    let newTicket = TicketModel()
                    newTicket.identifier = tickets[index].identifier
                    newTicket.ticketName = ticket
                    newTicket.isCompleted = false
                    newTicket.comment = tickets.filter({ $0.ticketName == ticket }).first!.comment
                    task.tickets.append(newTicket)
                }
            }
        }
    }

    /*チケットの削除*/
    func deleteTicket(index: Int, callback: (() -> Void)? = nil) {
        let task = tasks[index]
        let results = realm.objects(TaskItem.self)
        try! realm.write {
            for ticket in results[index].tickets {
                let tickets: [String] = task.tickets.map { $0.ticketName }
                // モデルに存在しない（削除された）チケットをデータベース上から削除
                if tickets.index(of: ticket.ticketName) == nil {
                    realm.delete(ticket)
                }
            }

            if let callback = callback {
                callback()
            }
        }
    }

    /*チケットの更新*/
    func updateTicket(index: Int) {
        let task = tasks[index]
        do {
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                for ticket in results[index].tickets {
                    let currentTicket = task.tickets.filter { $0.identifier == ticket.identifier }
                    ticket.isCompleted = currentTicket.first!.isCompleted
                    ticket.ticketName = currentTicket.first!.ticketName
                    ticket.comment = currentTicket.first!.comment
                }
                let task = results[index]
                task.setValue(Date(), forKey: TASK_LASTRESETDATE)
            }
        }
    }

    /*タスクの削除*/
    func deleteTask(index: Int, callback: (() -> Void)? = nil) {
        self.tasks.remove(at: index)
        do {
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                // 先にタスクデータの中の通知データも削除する
                results[index].taskNotifications.forEach({
                    realm.delete($0)
                })
                realm.delete(results[index])
                if let callback = callback {
                    callback()
                }
            }

        }

    }

    func editTask(currentTaskModel: TaskModel, beforeName: String, deleteNotifications: [String], completion: (() -> Void)) -> ValidateError? {
        do {
            let results = realm.objects(TaskItem.self).filter("id = \(currentTaskModel.id)").first

            let result = realm.objects(TaskItem.self)
            print(result)
            let tasks = result.map {$0.taskTitle}
            let temp = self.tasks.filter { $0.taskTitle == beforeName }.first!
            let index = self.tasks.index(of: temp)
            if currentTaskModel.taskTitle != beforeName, tasks.index(of: currentTaskModel.taskTitle) != nil {
                // 同じ名前のタスクが存在した場合はエラーを返す
                let error = ValidateError.taskValidError
                return error
            }

            // Realm用通知設定モデル作成
            let notificationsRealmArray = List<TaskNotifications>()
            for notification in currentTaskModel.notifications {
                let notificationRealmModel = TaskNotifications()
                notificationRealmModel.id = notification.id
                notificationRealmModel.identifier = notification.identifier
                notificationRealmModel.isActive = notification.isActive!
                notificationRealmModel.date = notification.date
                notificationsRealmArray.append(notificationRealmModel)
                // push通知設定
                Notifications().pushNotificationSet(resetTimeType: currentTaskModel.resetType, taskID: currentTaskModel.id, taskTitle: currentTaskModel.taskTitle, notificationModel: notification)
                Notifications().deleteNotifications(notifications: deleteNotifications)
            }
            let identifires = results?.taskNotifications.map { $0.identifier }
            // 既存identifierと一致しないnotificationモデルのみを抽出
            let notifications = notificationsRealmArray.filter { !(identifires?.contains($0.identifier))! }

            try! realm.write {
                results?.taskTitle = currentTaskModel.taskTitle
                results?.attri = currentTaskModel.attri
                results?.color = currentTaskModel.color
                results?.icon = currentTaskModel.icon
                results?.resetType = currentTaskModel.resetType
                for notice in notifications {
                    results?.taskNotifications.append(notice)
                }

                // 削除した通知をローカルデーからも削除する
                deleteNotifications.forEach {deleteNotice in
                    for notice in results!.taskNotifications {
                        if notice.identifier == deleteNotice {
                            realm.delete(notice)
                        }
                    }
                }
                self.tasks[index!].taskTitle = currentTaskModel.taskTitle
                completion()
            }
            return nil
        }
    }

    func checkResetModel(callback: @escaping () -> Void) {
        resetTaskModel(callback: {
            callback()
        })
    }

    /// タスクの状態のリセット
    func resetTaskModel(callback: @escaping () -> Void) {
        let result = realm.objects(TaskItem.self)
        for task in result {
            switch task.resetType {
            case 1: // 毎日
                let now = settingData.getDayFormat(date: Date())
                let lastResetDate = settingData.getDayFormat(date: task.lastResetDate!)
                if now > lastResetDate {
                    resetTask(task: task)
                }
            case 2: // 毎週
                let now = settingData.getDayFormat(date: Date())
                let lastResetDate = settingData.getDayFormat(date: task.lastResetDate!)
                let lastResetDateNextWeek = settingData.getNextWeekToMonday(date: lastResetDate)
                print(lastResetDate)
                print(lastResetDateNextWeek)
                if now >= lastResetDateNextWeek {
                    resetTask(task: task)
                }
            case 3: // 毎月
                let now = settingData.getMonthFormat(date: Date())
                let lastResetDate = settingData.getMonthFormat(date: task.lastResetDate!)
                print(now)
                print(lastResetDate)
                if now > lastResetDate {
                    resetTask(task: task)
                }
            default: break
            }
        }
        callback()
    }

    func resetTask(task: TaskItem) {
        try! realm.write {
            for ticket in task.tickets {
                ticket.isCompleted = false
                // tasksが既に取得されているので、そちらも一緒に反映させる
                self.tasks.filter { $0.id == task.id }.first!.tickets.forEach { $0.isCompleted = false }
            }
            task.setValue(Date(), forKey: TASK_LASTRESETDATE)
        }
    }

    // インクリメント用ID取得
    func lastId() -> Int {
        var nextId = 0
        do {
            var idArray = [Int]()
            for task in realm.objects(TaskItem.self) {
                idArray.append(task.id)
            }
            nextId = idArray.isEmpty ? 0 : idArray.max()! + 1
        }
        return nextId
    }
}
