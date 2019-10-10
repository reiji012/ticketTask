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
    private let progressSubject = BehaviorSubject(value: 0.0)
    private let ticketCountSubject = BehaviorSubject(value: 0)
    private let taskTitleSubject = BehaviorSubject(value: "")
    private let taskAttriSubject = BehaviorSubject(value: "")
    private let settingData = SettingData()
    
    var progress: Observable<Double> { return progressSubject.asObservable() }
    var ticketCout: Observable<Int> { return ticketCountSubject.asObserver() }
    var taskTitle: Observable<String> { return taskTitleSubject.asObserver() }
    var taskAttri: Observable<String> { return taskAttriSubject.asObserver() }
    var weatherIconImage: UIImage?
    
    var delegate: MainViewControllerProtocol?

    var taskID: Int?
    var taskLocalDataModel: TaskLocalDataModel?
    var wetherModel: WetherModel?
    var todayWetherInfo: Dictionary<String,Any>?
    var tasks: [[String:Any]]?
    var taskName: String? {
        didSet {
            self.taskTitleSubject.onNext(self.taskName!)
        }
    }
    func taskCount() -> Int {
        return taskLocalDataModel!.tasks!.count
    }
    var attri: String?
    
    var iconImage: UIImage?
    var iconString: String?
    var taskColor: TaskColor?
    var resetTypeIndex: Int?
    
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
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        wetherModel = WetherModel.sharedManager
    }
    
    // タスクのModelを取得する
    init(taskName: String) {
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        task = taskLocalDataModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        self.iconString = (task!["icon"] as! String)
        self.taskID = (task!["id"] as! Int)
        self.iconImage = UIImage(named: iconString!)!.withRenderingMode(.alwaysTemplate)
    }
    
    func getTask(taskName: String) {
        task = taskLocalDataModel?.getTask(taskName: taskName)
        self.taskName = (task!["title"] as! String)
        self.attri = (task!["attri"] as! String)
        self.tickets = (task!["tickets"] as! [String:Bool])
        self.iconString = (task!["icon"] as! String)
        self.taskID = (task!["id"] as! Int)
        setColor(colorString: (task!["color"] as! String))
        countProgress()
    }
    
    func setColor(colorString: String) {
        switch colorString {
        case "blue":
            taskColor = .blue
        case "orange":
            taskColor = .orange
        case "red":
            taskColor = .red
        case "green":
            taskColor = .green
        default:
            taskColor = .blue
        }
    }
    
    func createTask(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>, resetType: Int) -> ValidateError? {
        let error = taskLocalDataModel?.createTask(taskName: taskName, attri: attri, colorStr: colorStr, iconStr:  iconStr, tickets:tickets, resetType: resetType)
        if (error != nil) {
            return error
        } else {
            self.tasks = self.taskLocalDataModel!.tasks
            return nil
        }
    }
    
    func addTicket(ticketName: String) {
        let ticketArray = tickets?.keys
        if ticketArray!.index(of: ticketName) != nil {
            delegate?.showValidateAlert(error: .ticketValidError)
            return
        }
        self.tickets!.updateValue(false, forKey: ticketName)
    }
    
    func changeTicketCompleted(ticketName: String,completed: Bool) {
        tickets![ticketName]! = completed
    }
    
    func updateModel(actionType :ActionType, callback: (() -> Void)? = nil) {
        taskLocalDataModel!.taskUpdate(id: self.taskID!,tickets: self.tickets!, actionType: actionType, callback: {
            if let callback = callback {
                callback()
                self.delegate?.didChangeTaskCount(taskCount: self.taskCount())
            }
        })
        task = taskLocalDataModel?.getTask(taskName: self.taskName!)
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
    
    func getTaskData() {
        taskLocalDataModel?.getTaskData()
        tasks = taskLocalDataModel!.tasks!
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
        self.iconImage = UIImage(named: "")
    }
    
    func checkIsTaskEmpty() {
        let isTaskEmpty = self.taskLocalDataModel!.tasks?.isEmpty
        self.delegate?.setTaskEmptyViewState(isHidden: !(isTaskEmpty!))
        if !(isTaskEmpty!) {
            self.delegate?.createAllTaskViews()
        }
        
    }
}
