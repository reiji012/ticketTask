//
//  TaskModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TaskModel {

    var tasks: [[String:Any]]?
    
    static var sharedManager: TaskModel = {
        return TaskModel()
    }()
    private init() {
        var tmp: Array<Any> = []
        var array = ["title":"","attri":"","tickets":[]] as [String : Any]
        for i in 0..<10 {
            let taskTitle = "task\(i + 1)"
            let attri = i % 2 == 0 ? "a" : "b"
            let tickets = i % 2 == 0 ? ["banana":false,"tomato":true,"apple":true] : ["bread":false,"milk":false,"stake":true,"rice":false,"carry":false]
            array["title"] = taskTitle
            array["attri"] = attri
            array["tickets"] = tickets
            
            tmp.append(array)
        }
        tasks = (tmp as! [[String : Any]])
    }
    
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
}
