//
//  TaskViewModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RxSwift

class TaskViewModel: NSObject {
    
    private let progressSubject = BehaviorSubject(value: 0.0)
    
    var progress: Observable<Double> { return progressSubject.asObservable() }

    var taskModel: TaskModel?
    var tasks: [[String:Any]]?
    var taskName: String?
    var taskCount: Int?
    var attri: String?
    var tickets: [String:Bool]? = nil {
        didSet {
            self.updateModel()
        }
    }
    var completedProgress: Double?
    var task: Dictionary<String, Any>?
    var ticketCout: Int?
    
    
    
    override init() {
        taskModel = TaskModel.sharedManager
        tasks = taskModel!.tasks!
        taskCount = tasks?.count
    }
    
    // タスクのModelを取得する
    init(taskName: String) {
        taskModel = TaskModel.sharedManager
        task = taskModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        self.ticketCout = tickets?.count
    }
    
    func getTask(taskName: String) {
        task = taskModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        self.ticketCout = tickets?.count
        countProgress()
    }
    
    func createTask(taskName: String, attri: String, tickets:Array<String>) {
        taskModel?.createTask(taskName: taskName, attri: attri, tickets:tickets)
        self.taskCount! += 1
    }
    
    func changeTicketCompleted(ticketName: String,completed: Bool) {
        tickets![ticketName]! = completed
    }
    
    func updateModel() {
        taskModel!.taskUpdate(taskName: self.taskName!,tickets: self.tickets!)
        task = taskModel?.getTask(taskName: self.taskName!)
        self.ticketCout = tickets?.count

        self.countProgress()
    }
    
    func countProgress() {
        var compCount = 0
        for value in self.tickets!.values {
            compCount += value ? 1 : 0
        }
        
        let num = round(Double(compCount)/Double(self.ticketCout!)*100)/100
        self.completedProgress = num
        changeProgress()
    }
    
    func changeProgress() {
        let progress = self.completedProgress!
        progressSubject.onNext(progress)
    }
}
