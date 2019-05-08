//
//  TaskModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TaskModel {

    var tasks = [Any]()
    
    static var sharedManager: TaskModel = {
        return TaskModel()
    }()
    private init() {
        var array = ["title":"","attri":"","tasks":[]] as [String : Any]
        for i in 0..<10 {
            let taskTitle = "task\(i)"
            let attri = i % 2 == 0 ? "a" : "b"
            let tickets = i % 2 == 0 ? ["banana":false,"tomato":true,"apple":true] : ["bread":false,"milk":false]
            array["title"] = taskTitle
            array["attri"] = attri
            array["tickets"] = tickets
            
            tasks.append(array)
        }
    }
    
    func getTask(taskName: String) -> Dictionary<String, Any> {
        var currentTask: Dictionary<String, Any> = [:]
        for task in tasks {
            var tmpTask = task as! Dictionary<String, Any>
            if tmpTask["title"] as! String == taskName {
                currentTask = tmpTask
            }
        }
        return currentTask
    }
}
