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

    var tasks: [[String:Any]]?
    var lastCreateTask = ["title":"","attri":"","tickets":[]] as [String : Any]
    
    static var sharedManager: TaskModel = {
        return TaskModel()
    }()
    private init() {
        let testArray = ["朝の準備","晩御飯","就寝の準備","お仕事","勉強の進捗"]
        var tmpArray: Array<Any> = []
        var array = ["title":"","attri":"","tickets":[]] as [String : Any]
        for (index,value) in testArray.enumerated() {
            let taskTitle = value
            let attri = index % 2 == 0 ? "a" : "b"
            var tickets = index % 2 == 0 ? ["banana":false,"tomato":true,"apple":true] : ["bread":false,"milk":false,"stake":true,"rice":false,"carry":false]
            array["title"] = taskTitle
            array["attri"] = attri
            
            
            switch value {
            case "朝の準備": tickets = ["歯磨き":false,"朝ごはん":true,"新聞":true,"シャワー":true,"ニュース":false,"魚":false,"テレビ":true,"布団の処理":true,"鍵":true]
            case "晩御飯": tickets = ["魚":false,"サラダ":true,"牛肉":true,"牛乳":true]
            case "就寝の準備": tickets = ["歯磨き":false,"テレビ":true,"布団の準備￥":true,"シャワー":true]
            case "お仕事": tickets = ["朝のタスク":false,"デスクの掃除":true,"事務処理":true,"午後のタスク":true]
            case "勉強の進捗": tickets = ["学校の宿題":false,"夏休みの宿題":true,"受験勉強":true,"数学10ページ":true]
            default: break
            }
            
            array["tickets"] = tickets
            tmpArray.append(array)
        }
        tasks = (tmpArray as! [[String : Any]])
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
    }
    
    func getTaskData() {
        do {
            let realm = try Realm()
            let results = realm.objects(TaskItem.self)
            var a = results.count
            if  results.count == 0 {
                print(results)
                self.dataFirstInit()
            }
            print(results)

        
            try! realm.write {
                realm.add(TasksData())
                print("データベース追加後", results.count)
                print(results)
            }
            
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
                "taskTitle": "朝の準備",
                "attri": "a",
                "tickets": [["taskName"    : "朝の準備",
                            "ticketName"  : "歯磨き",
                            "isCompleted" : false],
                            ["taskName"    : "朝の準備",
                             "ticketName"  : "歯磨き",
                             "isCompleted" : false]]
            ]
            let task2Dictionary:[String:Any] = [
                "taskTitle": "お仕事",
                "attri": "b",
                "tickets": [["taskName"    : "お仕事",
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
