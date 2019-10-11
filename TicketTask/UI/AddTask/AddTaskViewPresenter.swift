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
    func touchCreateButton(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:[TicketsModel], resetType: Int)
    func removeTicket(index: IndexPath)
    func selectedColor(color: TaskColor)
    func selectedIcon(iconString: String)
}


import Foundation

class AddTaskViewPresenter: AddTaskViewPresenterProtocol, ErrorAlert {

    
    var tickets: [TicketsModel]! = []
    var view: AddTaskViewControllerProtocol!
    var taskLocalDataModel: TaskLocalDataModel?
    var ticketArray = [String]()
    var currentColor: TaskColor
    var currentTaskModel: TaskModel!
    
    init(vc: AddTaskViewControllerProtocol) {
        view = vc
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        tickets = []
        currentColor = .orange
        currentTaskModel = TaskModel(id: (taskLocalDataModel?.lastId())!)
    }
    
    func viewDidLoad() {
        
    }
    
    func touchAddTicketButton(text: String) {
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
    
    func touchCreateButton(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:[TicketsModel], resetType: Int) {
        
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
        
        let error = taskLocalDataModel?.createTask(taskName: taskName, attri: attri, colorStr: colorStr, iconStr:  iconStr, tickets:tickets, resetType: resetType)
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
        view.setIconImage()
        view.setGradationColor()
    }
    
    func selectedIcon(iconString: String) {
        currentTaskModel.icon = iconString
        view.setIconImage()
    }
}
