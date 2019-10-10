//
//  AddTaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/01.
//  Copyright © 2019 松村礼二. All rights reserved.
//

protocol AddTaskViewPresenterProtocol {
    var tickets: [String]! { get }
    var currentColor: TaskColor { get set }
    func viewDidLoad()
    func touchAddTicketButton(text: String)
    func touchCreateButton(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>, resetType: Int)
    func removeTicket(index: IndexPath)
}


import Foundation

class AddTaskViewPresenter: AddTaskViewPresenterProtocol, ErrorAlert {
    var tickets: [String]! = [String]()
    var view: AddTaskViewControllerProtocol!
    var taskLocalDataModel: TaskLocalDataModel?
    var ticketArray = [String]()
    var currentColor: TaskColor
    
    init(vc: AddTaskViewControllerProtocol) {
        view = vc
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        tickets = []
        currentColor = .orange
    }
    
    func viewDidLoad() {
        
    }
    
    func touchAddTicketButton(text: String) {
        if ticketArray.index(of: text) == nil {
            self.tickets.append(text)
            ticketArray.append(text)
            view.didAddTicket()
        } else {
            guard let viewController = view as? AddTaskViewController else {
                return
            }
            createErrorAlert(error: .ticketValidError, massage: "", view: viewController)
        }
    }
    
    func touchCreateButton(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>, resetType: Int) {
        
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
}
