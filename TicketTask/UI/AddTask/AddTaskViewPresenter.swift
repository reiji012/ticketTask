//
//  AddTaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/01.
//  Copyright © 2019 松村礼二. All rights reserved.
//

protocol AddTaskViewPresenterProtocol {
    var tickets: [TicketsModel]! { get }
    var currentColor: TaskColor { get set }
    var currentTaskModel: TaskModel! { get }
    func viewDidLoad()
    func touchAddTicketButton(text: String)
    func touchCreateButton(taskName: String)
    func removeTicket(index: IndexPath)
    func selectedColor(color: TaskColor)
    func selectedIcon(iconString: String)
    func selectedResetTypeIndex(index: Int)
}


import Foundation
import UIKit

class AddTaskViewPresenter: AddTaskViewPresenterProtocol, ErrorAlert {

    
    var tickets: [TicketsModel]! = []
    var view: AddTaskViewControllerProtocol!
    var taskLocalDataModel: TaskLocalDataModel?
    var ticketArray = [String]()
    var currentTaskModel: TaskModel!
    
    var currentIcon: UIImage?
    
    var currentIconString: String? {
        didSet {
            currentTaskModel.icon = currentIconString!
            currentIcon = UIImage(named: currentIconString!)
        }
    }
    
    var currentColor: TaskColor {
        didSet {
            currentTaskModel.color = currentColor.colorString
        }
    }
    
    init(vc: AddTaskViewControllerProtocol) {
        view = vc
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        tickets = []
        currentColor = .orange
        currentTaskModel = TaskModel(id: (taskLocalDataModel?.lastId())!)
        currentTaskModel = TaskModel(id: (taskLocalDataModel?.lastId())!)
    }
    
    func viewDidLoad() {
        currentTaskModel.color = currentColor.colorString
        currentIconString = "icon-0"
        currentTaskModel.resetType = 0
        view.initSetState()
    }
    
    func touchAddTicketButton(text: String) {
         // TODO: if currentTaskModel.tickets.map({$0.ticketName}).index(of: text) != nil
        if ticketArray.index(of: text) == nil {
            let ticketModel = TicketsModel().initiate(ticketName: text)
            self.tickets.append(ticketModel)
            currentTaskModel.tickets.append(ticketModel)
            ticketArray.append(text)
            view.didAddTicket()
        } else {
            guard let viewController = view as? AddTaskViewController else {
                return
            }
            createErrorAlert(error: .ticketValidError, massage: "", view: viewController)
        }
    }
    
    func touchCreateButton(taskName: String) {
        
        let isEmptyTaskName = taskName.isEmpty
        let isEmptyTicketCount = tickets.count == 0
        
        if isEmptyTaskName || isEmptyTicketCount {
            var massage = ""
            massage += isEmptyTaskName ? "タイトルが入力されていません\n" : ""
            massage += isEmptyTicketCount ? "チケットを一つ以上追加してください\n" : ""
            guard let viewController = view as? AddTaskViewController else {
                return
            }
            createErrorAlert(error: .inputValidError, massage: massage, view: viewController)
            return
        }
        currentTaskModel.taskTitle = taskName
        let error = taskLocalDataModel?.createTask(taskModel: currentTaskModel)
        if let error = error {
            guard let viewController = view as? AddTaskViewController else {
                return
            }
            createErrorAlert(error: error, massage: "", view: viewController)
            return
        }
        view.didTaskCreated()
    }
    
    func removeTicket(index: IndexPath) {
        tickets.remove(at: index.row)
    }
    
    func selectedColor(color: TaskColor) {
        currentColor = color
        view.setColorView()
        view.setGradationColor()
    }
    
    func selectedIcon(iconString: String) {
        currentIconString = iconString
        view.setIconImage()
    }
    
    func selectedResetTypeIndex(index: Int) {
        currentTaskModel.resetType = index
    }
}
