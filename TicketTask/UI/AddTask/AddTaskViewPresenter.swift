//
//  AddTaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/01.
//  Copyright © 2019 松村礼二. All rights reserved.
//

protocol AddTaskViewPresenterProtocol {
    var tickets: [String]! { get }
    func viewDidLoad()
    func touchAddTicketButton(text: String)
    func touchCreateButton(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>, resetType: Int)
    func removeTicket(index: IndexPath)
}


import Foundation

class AddTaskViewPresenter: AddTaskViewPresenterProtocol {
    var tickets: [String]! = [String]()
    var viewController: AddTaskViewControllerProtocol!
    var taskModel: TaskModel?
    var ticketArray = [String]()
    
    init(vc: AddTaskViewControllerProtocol) {
        viewController = vc
        taskModel = TaskModel.sharedManager
        tickets = []
    }
    
    func viewDidLoad() {
        
    }
    
    func touchAddTicketButton(text: String) {
        if ticketArray.index(of: text) == nil {
            self.tickets.append(text)
            ticketArray.append(text)
            viewController.didAddTicket()
        } else {
            createErrorMassgate(error: .ticketValidError)
        }
    }
    
    func touchCreateButton(taskName: String, attri: String, colorStr: String, iconStr: String, tickets:Array<String>, resetType: Int) {
        
        let isEmptyTaskName = taskName.isEmpty
        let isEmptyTicketCount = tickets.count == 0
        
        if isEmptyTaskName, isEmptyTicketCount {
            var massage = ""
            massage += isEmptyTaskName ? "タイトルが入力されていません/n" : ""
            massage += isEmptyTicketCount ? "チケットを一つ以上追加してください/n" : ""
            createErrorMassgate(error: .inputValidError, massage: massage)
            return
        }
        
        let error = taskModel?.createTask(taskName: taskName, attri: attri, colorStr: colorStr, iconStr:  iconStr, tickets:tickets, resetType: resetType)
        if let error = error {
            createErrorMassgate(error: error)
            return
        }
        viewController.didTaskCreated()
    }
    
    func removeTicket(index: IndexPath) {
        tickets.remove(at: index.row)
    }
    
    private func createErrorMassgate(error: ValidateError, massage: String? = "") {
        var _massage = ""
        var title = ""
        
        switch error {
        case .inputValidError:
            title = "入力エラー"
            _massage = massage!
        case .taskValidError:
            title = "データベースエラー"
            _massage = error.rawValue
        case .ticketValidError:
            title = "入力エラー"
            _massage = error.rawValue
        default:
            title = "保存に失敗しました"
        }
        
        viewController.showValidateAlert(title: title, massage: _massage)
    }
}
