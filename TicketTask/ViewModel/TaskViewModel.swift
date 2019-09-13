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
    
    private let wetherData = WetherAPIRequest()
    private let gradationColors = TicketTaskColor()
    private let progressSubject = BehaviorSubject(value: 0.0)
    private let ticketCountSubject = BehaviorSubject(value: 0)
    private let taskTitleSubject = BehaviorSubject(value: "")
    private let taskAttriSubject = BehaviorSubject(value: "")
    
    var progress: Observable<Double> { return progressSubject.asObservable() }
    var ticketCout: Observable<Int> { return ticketCountSubject.asObserver() }
    var taskTitle: Observable<String> { return taskTitleSubject.asObserver() }
    var taskAttri: Observable<String> { return taskAttriSubject.asObserver() }
    var weatherIconImage: UIImage?
    
    var delegate: MainDelegate?

    var taskID: Int?
    var taskModel: TaskModel?
    var wetherModel: WetherModel?
    var todayWetherInfo: Dictionary<String,Any>?
    var tasks: [[String:Any]]?
    var taskName: String?
    func taskCount() -> Int {
        return taskModel!.tasks!.count
    }
    var attri: String?
    
    var iconImage: UIImage?
    var iconString: String?
    var taskColor: UIColor?
    var colorString: String?
    
    var actionType: ActionType = .taskUpdate
    
    var tickets: [String:Bool]? = nil {
        didSet(value) {
            self.updateModel(actionType: self.actionType)
            self.actionType = .ticketUpdate
        } willSet(value) {
            ticketCountSubject.onNext(value!.count)
        }
    }
    var completedProgress: Double?
    var task: Dictionary<String, Any>?
    
    override init() {
        taskModel = TaskModel.sharedManager
        wetherModel = WetherModel.sharedManager
    }
    
    // タスクのModelを取得する
    init(taskName: String) {
        taskModel = TaskModel.sharedManager
        task = taskModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        self.iconString = (task!["icon"] as! String)
        self.colorString = (task!["color"] as! String)
        self.taskID = (task!["id"] as! Int)
        self.iconImage = UIImage(named: iconString!)!.withRenderingMode(.alwaysTemplate)
    }
    
    func getTask(taskName: String) {
        task = taskModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        self.iconString = (task!["icon"] as! String)
        self.colorString = (task!["color"] as! String)
        self.taskID = (task!["id"] as! Int)
        setColor()
        countProgress()
    }
    
    func setColor() {
        switch colorString {
        case gradationColors.BLUE:
            taskColor = gradationColors.ticketTaskBlue_1
        case gradationColors.ORANGE:
            taskColor = gradationColors.ticketTaskOrange_1
        case gradationColors.RED:
            taskColor = gradationColors.ticketTaskRed_1
        case gradationColors.GREEN:
            taskColor = gradationColors.ticketTaskGreen_1
        default:
            taskColor = gradationColors.ticketTaskBlue_1
        }
    }
    
    func createTask(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>) -> ValidateError? {
        let error = taskModel?.createTask(taskName: taskName, attri: attri, colorStr: colorStr, iconStr:  iconStr, tickets:tickets)
        if (error != nil) {
            return error
        } else {
            self.tasks = self.taskModel!.tasks
            return nil
        }
    }
    
    func addTicket(ticketName: String) -> ValidateError? {
        let ticketArray = tickets?.keys
        if ticketArray!.index(of: ticketName) != nil {
            return .ticketValidError
        }
        self.tickets!.updateValue(false, forKey: ticketName)
        return nil
    }
    
    func changeTicketCompleted(ticketName: String,completed: Bool) {
        tickets![ticketName]! = completed
    }
    
    func updateModel(actionType :ActionType) {
        taskModel!.taskUpdate(id: self.taskID!,tickets: self.tickets!, actionType: actionType)
        task = taskModel?.getTask(taskName: self.taskName!)
        self.countProgress()
        delegate?.didChangeTaskCount(taskCount: self.taskCount())
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
    
    func getTaskData() {
        taskModel?.getTaskData()
        tasks = taskModel!.tasks!
    }
    
    func taskEdited(afterTaskName: String, afterTaskAttr: String, color: UIColor, colorStr: String, image: UIImage, imageStr: String) {
//        self.taskModel?.editTask(afterTaskName: afterTaskName, afterTaskAttr: afterTaskAttr, id: self.taskID!)
        self.taskModel?.editTask(afterTaskName: afterTaskName, afterTaskAttr: afterTaskAttr, colorStr: colorStr, imageStr: imageStr, id: self.taskID!)
        self.taskName = afterTaskName
        self.attri = afterTaskAttr
        self.taskColor = color
        self.colorString = colorStr
        self.iconImage = image
        self.iconString = imageStr
        taskTitleSubject.onNext(afterTaskName)
        taskAttriSubject.onNext(afterTaskAttr)
    }
    
    func setupWetherInfo() {
        wetherModel?.fetchWetherInfo(callback: {
            self.todayWetherInfo = self.wetherModel?.getWetherTodayInfo()
            guard let delegate = self.delegate else {
                return
            }
            self.weatherIconImage = self.wetherModel?.weatherIconImage
            delegate.setWeatherInfo()
        })
    }
    
    func setupIcon() {
        let iconString = self.task
        self.iconImage = UIImage(named: "")
    }
    
    func checkIsTaskEmpty() {
        let isTaskEmpty = self.taskModel!.tasks?.isEmpty
        self.delegate?.setTaskEmptyViewState(isHidden: !(isTaskEmpty!))
        if !(isTaskEmpty!) {
            self.delegate?.createTaskViews()
        }
        
    }
}
