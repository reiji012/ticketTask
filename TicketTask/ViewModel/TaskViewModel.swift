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
    private let ticketCountSubject = BehaviorSubject(value: 0)
    
    var progress: Observable<Double> { return progressSubject.asObservable() }
    var ticketCout: Observable<Int> { return ticketCountSubject.asObserver() }


    var taskModel: TaskModel?
    var tasks: [[String:Any]]?
    var taskName: String?
    func taskCount() -> Int {
        return taskModel!.tasks!.count
    }
    var attri: String?
    
    let actionType: ActionType = .taskUpdate
    
    var tickets: [String:Bool]? = nil {
        didSet(value) {
            self.updateModel(actionType: .ticketUpdate)
        } willSet(value) {
            ticketCountSubject.onNext(value!.count)
        }
    }
    var completedProgress: Double?
    var task: Dictionary<String, Any>?
    
    override init() {
        taskModel = TaskModel.sharedManager
        tasks = taskModel!.tasks!
    }
    
    // タスクのModelを取得する
    init(taskName: String) {
        taskModel = TaskModel.sharedManager
        task = taskModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
    }
    
    func getTask(taskName: String) {
        task = taskModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        countProgress()
    }
    
    func createTask(taskName: String, attri: String, tickets:Array<String>) {
        taskModel?.createTask(taskName: taskName, attri: attri, tickets:tickets)
    }
    
    func changeTicketCompleted(ticketName: String,completed: Bool) {
        tickets![ticketName]! = completed
    }
    
    func updateModel(actionType :ActionType) {
        taskModel!.taskUpdate(taskName: self.taskName!,tickets: self.tickets!, actionType: actionType)
        task = taskModel?.getTask(taskName: self.taskName!)
        self.countProgress()
    }
    
    func countProgress() {
        var compCount = 0
        for value in self.tickets!.values {
            compCount += value ? 1 : 0
        }
        
        let num = round(Double(compCount)/Double(self.tickets!.count)*100)/100
        self.completedProgress = num
        changeProgress()
    }
    
    func changeProgress() {
        let progress = self.completedProgress!
        progressSubject.onNext(progress)
    }
}
