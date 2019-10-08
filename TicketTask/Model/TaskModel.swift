//
//  TaskModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RealmSwift

class TaskModel {
    
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

    var tasks: [[String:Any]]?
    var lastCreateTask = ["title":"","attri":"","tickets":[], "id":0] as [String : Any]
    
    var realm: Realm!
    
    static var sharedManager: TaskModel = {
        return TaskModel()
    }()
    
    private init() {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        self.realm = try! Realm(configuration: config)
    }
    
    /*タスクを取得する*/
    func getTask(taskName: String) -> Dictionary<String, Any> {
        var currentTask: Dictionary<String, Any> = [:]
        for task in tasks! {
            var tmpTask = task 
            if tmpTask["title"] as! String == taskName {
                currentTask = tmpTask
            }
        }
        return currentTask
    }
    
    /*タスクを作成する*/
    func createTask(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>, resetType: Int) -> ValidateError? {
        
        if taskName.isEmpty, tickets.count == 0 {
            var error: ValidateError = .inputValidError
            return error
        }
        
        var taskArray = ["title":"","attri":"","icon":"","color":"","category":"","tickets":[], "id":0] as [String : Any]
        var ticketsArray: [String : Bool] = [:]
        var ticketsRealmArray: [[String : Any]] = []
        let lastID = self.lastId()
        taskArray["title"] = taskName
        taskArray["attri"] = attri
        taskArray["icon"] = iconStr
        taskArray["color"] = colorStr
        for ticket in tickets {
            ticketsArray.updateValue(false, forKey: ticket)
            let array = ["ticketName"  : ticket,
                         "isCompleted" : false] as [String : Any]
             ticketsRealmArray.append(array)
        }
        taskArray["id"] = lastID
        taskArray["tickets"] = ticketsArray
        
        
        do {
            let results = realm.objects(TaskItem.self)
            print(results)
            let tasks = results.map {$0.taskTitle}
            if tasks.index(of: taskName) != nil {
                // 同じ名前のタスクが存在した場合はエラーを返す
                let error = ValidateError.taskValidError
                return error
            }
            
            let taskDictionary:[String:Any] = [
                TASK_TITLE: taskName,
                TASK_ATTRI: attri,
                TASK_COLOR: colorStr,
                TASK_ICON: iconStr,
                TASK_TICKETS: ticketsRealmArray,
                TASK_RESET_TYPE: resetType
            ]
            
            
            let taskItem = TaskItem(value: taskDictionary)
            
            try! realm.write {
                taskItem.id = lastID
                realm.add(taskItem)
                print("データベース追加後", results.count)
                print(results)
            }
            // タスク追加に成功した時にtasksパラメータにタスクを追加
            self.tasks?.append(taskArray)
            self.lastCreateTask = taskArray
            return nil
        }
        catch {
            return (error as! ValidateError)
        }
        
    }
    
    /*タスクの更新*/
    func taskUpdate(id: Int, tickets:[String:Bool], actionType: ActionType, callback: (() -> Void)? = nil) {
        var indexPath = 0
        for (index, task) in self.tasks!.enumerated(){
            if (task["id"] as! Int) == id {
                self.tasks![index]["tickets"] = tickets
                indexPath = index
            }
        }
        // アクションによって処理を変える
        switch actionType {
        case .taskDelete:
            self.deleteTask(index: indexPath, callback:  {
                if let callback = callback {
                    callback()
                }
            })
        case .ticketUpdate:
            self.updateTicket(index: indexPath)
        case .ticketDelete:
            self.deleteTicket(index: indexPath, callback: {
                if let callback = callback {
                    callback()
                }
            })
        case .ticketCreate:
            self.addTicket(tickets: [String](tickets.keys), id: id)
        default:
            return
        }
    }
    
    /*チケットの追加*/
    func addTicket(tickets:[String], id: Int) {
        do {
            let task = realm.objects(TaskItem.self).filter("id = \(id)").first
            print(task)
            var ticketArray = [String]()
            ticketArray = task!.tickets.map { $0.ticketName }
            
            for ticket in tickets {
                if ticketArray.index(of: ticket) == nil {
                    let newTicket = TicketModel()
                    newTicket.ticketName = ticket
                    try! realm.write {
                        task!.tickets.append(newTicket)
                    }
                }
            }
            
            print(task)
            
        }
        catch {
            print(error)
        }
    }
    
    /*チケットの削除*/
    func deleteTicket(index: Int, callback: (() -> Void)? = nil) {
        guard let tasks = self.tasks else { return }
        let task = tasks[index]
        do {
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                for ticket in results[index].tickets {
                    var tickets = task["tickets"] as! [String:Bool]
                    // モデルに存在しない（削除された）チケットをデータベース上から削除
                    if tickets[ticket.ticketName] == nil {
                        realm.delete(ticket)
                    }
                }
                
                if let callback = callback {
                    callback()
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    /*チケットの更新*/
    func updateTicket(index: Int) {
        guard let tasks = self.tasks else { return }
        let task = tasks[index]
        do {
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                for ticket in results[index].tickets {
                    var tickets = task["tickets"] as! [String:Bool]
                    // モデルからチケットが削除されていればデータベース上のチケットも削除する
                    if tickets[ticket.ticketName] == nil {
                        return
                    }
//                    ticket.ticketName = self.tasks![index]["tickets"] as! String
                    ticket.isCompleted = (tickets[ticket.ticketName])!
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    /*タスクの削除*/
    func deleteTask(index: Int, callback: (() -> Void)? = nil) {
        self.tasks?.remove(at: index)
        do {
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                realm.delete(results[index])
                if let callback = callback {
                    callback()
                }
            }
            
        }
        catch {
            print (error)
        }
        
    }
    
    func editTask(afterTaskName: String, afterTaskAttr: String, colorStr: String, imageStr: String, id: Int, completion: (() -> Void)) -> ValidateError? {
        do {
            let results = realm.objects(TaskItem.self).filter("id = \(id)")
            
            let result = realm.objects(TaskItem.self)
            print(result)
            let tasks = result.map {$0.taskTitle}
            if tasks.index(of: afterTaskName) != nil {
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
        catch {
            print(error)
        }
    }
    
    /*Realmからデータを取得する*/
    func getTaskData() {
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        do {
            let results = realm.objects(TaskItem.self).sorted(byKeyPath: "id", ascending: true)
            if  results.count == 0 {
                print(results)
//                self.dataFirstInit()
            }
            print(results)

            
            //データを取り出してモデルに反映する
            var tmpArray: Array<Any> = []
            var array = ["title":"","attri":"","icon":"","color":"","category":"","tickets":[], "id":0] as [String : Any]
            for task in results{
                array["title"] = task[TASK_TITLE]!
                array["attri"] = task[TASK_ATTRI]
                array["icon"] = task[TASK_ICON]
                array["color"] = task[TASK_COLOR]
                array["category"] = task[TASK_CATEGORY]
                array["id"] = task.id
                var ticketArray: [String:Bool] = [:]
                let tickets = task[TASK_TICKETS]
                for ticket in tickets as! List<TicketModel> {
                    let ticketName = ticket[TICKET_NAME] as! String
                    let isCompleted = ticket[TICKET_IS_COMPLETED] as! Bool
                    ticketArray[ticketName] = isCompleted
                }
                array["tickets"] = ticketArray
                tmpArray.append(array)
            }
            self.tasks = (tmpArray as! [[String : Any]])
            
            print(tasks as Any)
            
        } catch {
            print(error)
        }

    }
    
    /// タスクの状態のリセット
    ///
    /// - Parameter resetType: リセットタイプ
    func checkResetModel(resetType: Int) {
        let result = realm.objects(TaskItem.self).filter("resetType == %@", resetType)
        for task in result {
            let lastResetDate = task.lastResetDate!
            let now = Date()
            if now > lastResetDate {
                try! realm.write {
                    for ticket in task.tickets {
                        ticket.isCompleted = false
                    }
                    task.setValue(now, forKey: TASK_LASTRESETDATE)
                }
            }
        }
        
    }
    
    func lastId() -> Int {
        var nextId = 0
        do {
            var idArray = [Int]()
            for task in realm.objects(TaskItem.self) {
                idArray.append(task.id)
            }
            nextId = idArray.isEmpty ? 0 : idArray.max()! + 1
        }
        catch {
            print(error)
        }
        return nextId
    }
}

