//
//  TaskLocalDataModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RealmSwift

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
    
    public init() {
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
        for task in results{
            let taskModel = TaskModel(id: task.id)
            taskModel.taskTitle = task.taskTitle
            taskModel.color = task.color
            taskModel.icon = task.icon
            taskModel.category = task.category
            taskModel.lastResetDate = task.lastResetDate
            taskModel.tickets = []
            var _tickets: [TicketsModel] = []
            let tickets = task.tickets
            for ticket in tickets {
                let _ticket = TicketsModel()
                _ticket.ticketName = ticket.ticketName
                _ticket.isCompleted = ticket.isCompleted
                _tickets.append(_ticket)
            }
            taskModel.tickets = _tickets
            self.tasks.append(taskModel)
        }
    }
    
    /*タスクを取得する*/
    func getTask(taskName: String) -> TaskModel {
        var currentTask: TaskModel?
        for task in tasks {
            if task.taskTitle == taskName {
                currentTask = task
            }
        }
        return currentTask!
    }
    
    /*タスクを作成する*/
    func createTask(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:[TicketsModel], resetType: Int) -> ValidateError? {
        
        if taskName.isEmpty || tickets.count == 0 {
            let error: ValidateError = .inputValidError
            return error
        }
        let lastID = self.lastId()
        // モデル作成
        let taskModel = TaskModel(id: lastID)
        taskModel.taskTitle = taskName
        taskModel.attri = attri
        taskModel.color = colorStr
        taskModel.icon = iconStr
        taskModel.tickets = tickets
    
        let results = realm.objects(TaskItem.self)
        print(results)
        let tasks = results.map {$0.taskTitle}
        if tasks.index(of: taskName) != nil {
            // 同じ名前のタスクが存在した場合はエラーを返す
            let error = ValidateError.taskValidError
            return error
        }
        
        // Realm用チケットモデル作成
        let ticketsRealmArray = List<TicketModel>()
        for ticket in tickets {
            let ticketRealmModel = TicketModel()
            ticketRealmModel.ticketName = ticket.ticketName
            ticketRealmModel.isCompleted = false
            ticketsRealmArray.append(ticketRealmModel)
        }
        
        // テンプレートから時刻を表示
        let f = DateFormatter()
        f.setTemplate(.date)
        let currentDay = f.string(from: Date())
        let day = f.date(from: currentDay)
        
        // Realm用タスクモデル作成
        let taskItem = TaskItem()
        taskItem.id = lastID
        taskItem.taskTitle = taskName
        taskItem.attri = attri
        taskItem.color = colorStr
        taskItem.icon = iconStr
        taskItem.tickets = ticketsRealmArray
        taskItem.lastResetDate = day!
        taskItem.resetType = resetType
        
        try! realm.write {
            realm.add(taskItem)
            print("データベース追加後", results.count)
            print(results)
        }
        // push通知設定
        Notifications().pushNotificationSet(resetTimeType: resetType, taskID: lastID)
        // タスク追加に成功した時にtasksパラメータにタスクを追加
        self.tasks.append(taskModel)
        self.lastCreateTask = taskModel
        return nil
        
    }
    
    /*タスクの更新*/
    func taskUpdate(id: Int, tickets:[TicketsModel], actionType: ActionType, callback: (() -> Void)? = nil) {
        var indexPath = 0
        for (index, task) in self.tasks.enumerated(){
            if task.id == id {
                task.tickets = tickets
                indexPath = index
            }
        }
        // アクションによって処理を変える
        switch actionType {
        case .taskDelete:
            // タスク削除
            self.deleteTask(index: indexPath, callback:  {
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
    func addTicket(tickets:[TicketsModel], id: Int) {
        let task = realm.objects(TaskItem.self).filter("id = \(id)").first
        let ticketArray: [String] = task!.tickets.map { $0.ticketName }
        let currentTicketArray: [String] = tickets.map { $0.ticketName }
        for ticket in currentTicketArray {
            if ticketArray.index(of: ticket) == nil {
                try! realm.write {
                    task!.tickets.append(TicketModel(value: [ticket:false]))
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
                    let currentTicket = task.tickets.filter { $0.ticketName == ticket.ticketName }
                    ticket.isCompleted = currentTicket.first!.isCompleted
                }
            }
        }
    }
    
    /*タスクの削除*/
    func deleteTask(index: Int, callback: (() -> Void)? = nil) {
        self.tasks.remove(at: index)
        do {
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                realm.delete(results[index])
                if let callback = callback {
                    callback()
                }
            }
            
        }
        
    }
    
    func editTask(afterTaskName: String, afterTaskAttr: String, colorStr: String, imageStr: String, id: Int, beforeName: String, completion: (() -> Void)) -> ValidateError? {
        do {
            let results = realm.objects(TaskItem.self).filter("id = \(id)")
            
            let result = realm.objects(TaskItem.self)
            print(result)
            let tasks = result.map {$0.taskTitle}
            if tasks.index(of: afterTaskName) != nil, afterTaskName != beforeName {
                // 同じ名前のタスクが存在した場合はエラーを返す
                let error = ValidateError.taskValidError
                return error
            }
            
            try! realm.write {
                results.setValue(afterTaskName, forKey: TASK_TITLE)
                results.setValue(afterTaskAttr, forKey: TASK_ATTRI)
                results.setValue(colorStr, forKey: TASK_COLOR)
                results.setValue(imageStr, forKey: TASK_ICON)
                completion()
            }
            return nil
        }
    }
    
    func checkResetModel() {
        for typeIndex in settingData.checkDate() {
            resetTaskModel(resetType: typeIndex)
        }
    }
    
    /// タスクの状態のリセット
    ///
    /// - Parameter resetType: リセットタイプ
    func resetTaskModel(resetType: Int) {
        let result = realm.objects(TaskItem.self).filter("resetType == %@", resetType)
        for task in result {
            let lastResetDate = task.lastResetDate!
            let now = settingData.getToday()
            if now > lastResetDate {
                try! realm.write {
                    for ticket in task.tickets {
                        ticket.isCompleted = false
                    }
                    task.setValue(now, forKey: TASK_LASTRESETDATE)
                }
                updateTicket(index: task.id)
            }
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
