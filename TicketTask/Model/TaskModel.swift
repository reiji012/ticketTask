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
    let TICKET_NAME = "ticketName"
    let TICKET_IS_COMPLETED = "isCompleted"

    var tasks: [[String:Any]]?
    var lastCreateTask = ["title":"","attri":"","tickets":[], "id":0] as [String : Any]
    
    static var sharedManager: TaskModel = {
        return TaskModel()
    }()
    
    private init() {

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
    func createTask(taskName: String, attri: String, tickets:Array<String>) -> ValidateError? {
        var taskArray = ["title":"","attri":"","tickets":[], "id":0] as [String : Any]
        var ticketsArray: [String : Bool] = [:]
        var ticketsRealmArray: [[String : Any]] = []
        let lastID = self.lastId()
        taskArray["title"] = taskName
        taskArray["attri"] = attri
        for ticket in tickets {
            ticketsArray.updateValue(false, forKey: ticket)
            let array = ["ticketName"  : ticket,
                         "isCompleted" : false] as [String : Any]
             ticketsRealmArray.append(array)
        }
        taskArray["id"] = lastID
        taskArray["tickets"] = ticketsArray
        self.tasks?.append(taskArray)
        self.lastCreateTask = taskArray
        
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            print(results)
            let tasks = results.map {$0.taskTitle}
            if tasks.index(of: taskName) != nil {
                let error = ValidateError.taskValidError
                return error
            }
            
            let taskDictionary:[String:Any] = [
                TASK_TITLE: taskName,
                TASK_ATTRI: attri,
                TASK_TICKETS: ticketsRealmArray
            ]
            
            
            let taskItem = TaskItem(value: taskDictionary)
            
            try! realm.write {
                taskItem.id = lastID
                realm.add(taskItem)
                print("データベース追加後", results.count)
                print(results)
            }
            return nil
        }
        catch {
            return (error as! ValidateError)
        }
        
    }
    
    /*タスクの更新*/
    func taskUpdate(id: Int, tickets:[String:Bool], actionType: ActionType) {
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
            self.deleteTask(index: indexPath)
        case .ticketUpdate:
            self.updateTicket(index: indexPath)
        case .ticketDelete:
            self.deleteTicket(index: indexPath)
        case .ticketCreate:
            self.addTicket(tickets: [String](tickets.keys), id: id)
        default:
            return
        }
    }
    
    /*チケットの追加*/
    func addTicket(tickets:[String], id: Int) {
        do {
            let realm = try Realm()
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
    func deleteTicket(index: Int) {
        guard let tasks = self.tasks else { return }
        let task = tasks[index]
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                for ticket in results[index].tickets {
                    var tickets = task["tickets"] as! [String:Bool]
                    // モデルに存在しない（削除された）チケットをデータベース上から削除
                    if tickets[ticket.ticketName] == nil {
                        realm.delete(ticket)
                    }
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
            let realm = try Realm()
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
    func deleteTask(index: Int) {
        self.tasks?.remove(at: index)
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            try! realm.write {
                realm.delete(results[index])
            }
            
        }
        catch {
            print (error)
        }
        
    }
    
    func editTask(afterTaskName: String, afterTaskAttr: String, id: Int) {
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self).filter("id = \(id)")
            
            try! realm.write {
                results.setValue(afterTaskName, forKey: TASK_TITLE)
                results.setValue(afterTaskAttr, forKey: TASK_ATTRI)
            }
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
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            if  results.count == 0 {
                print(results)
                self.dataFirstInit()
            }
            print(results)

            
            //データを取り出してモデルに反映する
            var tmpArray: Array<Any> = []
            var array = ["title":"","attri":"","tickets":[], "id":0] as [String : Any]
            for task in results{
                array["title"] = task[TASK_TITLE]!
                array["attri"] = task[TASK_ATTRI]
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
    
    /*
    初期データの挿入
     */
    func dataFirstInit() {
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            print(results)
            
            let task1Dictionary:[String:Any] = [
                TASK_TITLE: "朝の準備",
                TASK_ATTRI: "生活",
                TASK_TICKETS: [[
                                "ticketName"  : "歯磨き",
                                "isCompleted" : false],
                               [
                                "ticketName"  : "鍵を閉める",
                                "isCompleted" : false]]
            ]
            let task2Dictionary:[String:Any] = [
                TASK_TITLE: "お仕事",
                TASK_ATTRI: "仕事",
                TASK_TICKETS: [[
                                "ticketName"  : "データの入力",
                                "isCompleted" : false],
                               [
                                "ticketName"  : "書類のコピー",
                                "isCompleted" : false]]
            ]
            
            let taskItem1 = TaskItem(value: task1Dictionary)
            let taskItem2 = TaskItem(value: task2Dictionary)
            
            try! realm.write {
                realm.add(taskItem1)
                print("データベース追加後", results)
                taskItem2.id = self.lastId()
                realm.add(taskItem2)
                print("データベース追加後", results)
                print(results)
            }
            
        } catch {
            print("error")
        }
    }
    
    func lastId() -> Int {
        var nextId = 0
        do {
            let realm = try Realm()
            var idArray = [Int]()
            for task in realm.objects(TaskItem.self) {
                idArray.append(task.id)
            }
            nextId = idArray.max()! + 1
        }
        catch {
            print(error)
        }
        return nextId
    }
}

