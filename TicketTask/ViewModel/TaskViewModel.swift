//
//  TaskViewModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TaskViewModel: NSObject {

    var tasks: [ String:String] = [:]
    var taskName: String?
    var taskNames: [String] = []
    var attris: [String] = []
    
    var taskModel = TaskModel()
    
    override init() {
        taskModel.createArray()
        tasks = taskModel.tasks
        
        for task in tasks {
            taskNames.append(task.key)
            attris.append(task.value)
            print(taskNames)
        }
    }
}
