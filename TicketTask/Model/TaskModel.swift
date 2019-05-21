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
    var lastCreateTask = ["title":"","attri":"","tickets":[]] as [String : Any]
    
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
    func createTask(taskName: String, attri: String, tickets:Array<String>) {
        var taskArray = ["title":"","attri":"","tickets":[]] as [String : Any]
        var ticketsArray: [String : Bool] = [:]
        taskArray["title"] = taskName
        taskArray["attri"] = attri
        for ticket in tickets {
            ticketsArray.updateValue(false, forKey: ticket)
        }
        taskArray["tickets"] = ticketsArray
        self.tasks?.append(taskArray)
        self.lastCreateTask = taskArray
    }
    
    /*タスクの更新*/
    func taskUpdate(taskName: String, tickets:[String:Bool], actionType: ActionType) {
        var conceIndex = 0
        for (index, task) in self.tasks!.enumerated(){
            if (task["title"] as! String) == taskName {
                self.tasks![index]["tickets"] = tickets
                conceIndex = index
            }
        }
        switch actionType {
        case .taskDelete:
            self.deleteTask(index: conceIndex)
        default:
            return
        }
    }
    
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
    
    func getTaskData() {
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            if  results.count == 0 {
                print(results)
                self.dataFirstInit()
            }
            
            //データを取り出してモデルに反映する
            var tmpArray: Array<Any> = []
            var array = ["title":"","attri":"","tickets":[]] as [String : Any]
            for task in results{
                array["title"] = task[TASK_TITLE]!
                array["attri"] = task[TASK_ATTRI]
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
                TASK_ATTRI: "a",
                TASK_TICKETS: [["taskName"    : "朝の準備",
                            "ticketName"  : "歯磨き",
                            "isCompleted" : false],
                            ["taskName"    : "朝の準備",
                             "ticketName"  : "鍵を閉める",
                             "isCompleted" : false]]
            ]
            let task2Dictionary:[String:Any] = [
                TASK_TITLE: "お仕事",
                TASK_ATTRI: "b",
                TASK_TICKETS: [["taskName"    : "お仕事",
                             "ticketName"  : "データの入力",
                             "isCompleted" : false],
                            ["taskName"    : "お仕事",
                             "ticketName"  : "書類のコピー",
                             "isCompleted" : false]]
            ]
            
            let taskItem1 = TaskItem(value: task1Dictionary)
            let taskItem2 = TaskItem(value: task2Dictionary)
            
            try! realm.write {
                realm.add(taskItem1)
                realm.add(taskItem2)
                print("データベース追加後", results.count)
                print(results)
            }
            
        } catch {
            print("error")
        }
    }
}
