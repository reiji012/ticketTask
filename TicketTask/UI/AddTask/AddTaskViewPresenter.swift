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
    var content: TableCellModel? { get }
    func numberOfRow(tableView: UITableView) -> Int
    func cellIdentifier(tableView: UITableView) -> String
    func viewDidLoad()
    func touchAddTicketButton(text: String, comment: String)
    func touchCreateButton(taskName: String)
    func touchCheckButtonAsEdit(title: String, memo: String, identifier: String)
    func removeIndex(indexPath: IndexPath, tableView: UITableView)
    func selectedColor(color: TaskColor)
    func selectedIcon(iconString: String)
    func selectedResetTypeIndex(index: Int)
    func selectedTicketCell(index: Int, tableView: UITableView)
    func didDoneDatePicker(selectDate: Date)
    func didChengeNotificationActive(isActive: Bool, identifier: String)
}


import Foundation
import UIKit

class AddTaskViewPresenter: AddTaskViewPresenterProtocol, ErrorAlert {

    private var notifications: [Data] = []
    
    // MARK: - Public Propaty
    var tickets: [TicketsModel]! = []
    var view: AddTaskViewControllerProtocol!
    var taskLocalDataModel: TaskLocalDataModel?
    var ticketArray = [String]()
    var currentTaskModel: TaskModel!
    var currentIcon: UIImage?
    var content: TableCellModel?
    
    var currentIconString: String = "icon-0" {
        didSet {
            currentTaskModel.icon = currentIconString
            currentIcon = UIImage(named: currentIconString)
        }
    }
    
    var currentColor: TaskColor = .orange {
        didSet {
            currentTaskModel.color = currentColor.colorString
        }
    }
    
    /// セルの数を返す
    /// - Parameter tableView: tableView
    func numberOfRow(tableView: UITableView) -> Int {
        switch tableView.tag {
        case 1:
            // リマインダーテーブルの時
            self.content = .reminder
            return currentTaskModel.notifications.isEmpty ? 0 : currentTaskModel.notifications.count
        case 2:
            // チケットテーブルの時
            self.content = .ticket
            content = .ticket
            return tickets.count
        default:
            return 1
        }
    }
    
    /// Identifierの数を返す
    /// - Parameter tableView: tableView
    func cellIdentifier(tableView: UITableView) -> String {
        switch tableView.tag {
        case 1:
            // リマインダーテーブルの時
            self.content = .reminder
            return content!.cellIdentifier
        case 2:
            // チケットテーブルの時
            self.content = .ticket
            content = .ticket
            return content!.cellIdentifier
        default:
            return "cell"
        }
    }
    
    
    // MARK: - Initialize
    init(vc: AddTaskViewControllerProtocol) {
        view = vc
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        currentTaskModel = TaskModel(id: (taskLocalDataModel?.lastId())!)
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        currentTaskModel.color = currentColor.colorString
        currentTaskModel.resetType = 0
        currentTaskModel.icon = currentIconString
        view.configureColorAndIcon()
        createTaskNotification(id: 0, dateString: "18:45")
        view.configureAddTicketView()
        view.configureDelegates()
        view.configureNavigationItem()
    }
    
    // MARK: - Public Function
    func touchAddTicketButton(text: String, comment: String) {
        guard let viewController = view as? AddTaskViewController else {
            return
        }
        
        if text.isEmpty {
            // タイトルが入力されていなければエラー処理
            createErrorAlert(error: .inputValidError, massage: "タイトルを入力してください", view: viewController)
            return
        }
        
        if ticketArray.index(of: text) != nil {
            // 同じ名前のチケットが存在していたらエラー処理
            createErrorAlert(error: .ticketValidError, massage: "", view: viewController)
            return
        }
        
        let ticketModel = TicketsModel().initiate(ticketName: text, comment: comment)
        ticketModel.identifier = NSUUID().uuidString
        self.tickets.append(ticketModel)
        currentTaskModel.tickets.append(ticketModel)
        ticketArray.append(text)
        view.didAddOrEditTicket()
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
        view.didTaskDataCreated()
    }
    
    // 編集モードのチェックボタンをタッチ
    func touchCheckButtonAsEdit(title: String, memo: String, identifier: String) {
        guard let viewController = view as? AddTaskViewController else {
            return
        }
        
        let ticket = self.tickets.filter { $0.identifier == identifier }.first!
        
        if ticketArray.index(of: title) != nil, ticket.ticketName != title {
            // 同じ名前のチケットが存在していたらエラー処理
            createErrorAlert(error: .ticketValidError, massage: "", view: viewController)
            return
        }
        
        let index = self.tickets.index(of: ticket)
        self.tickets[index!].ticketName = title
        self.tickets[index!].comment = memo
        view.didAddOrEditTicket()
    }
    
    func removeIndex(indexPath: IndexPath, tableView: UITableView) {
        if tableView.tag == 1 {
            // リマインダー
            currentTaskModel.notifications.remove(at: indexPath.row)
            return
        }
        // チケット
        tickets.remove(at: indexPath.row)
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
    
    // チケット選択
    func selectedTicketCell(index: Int, tableView: UITableView) {
        if tableView.tag == 1 {
            // tableViewがリマインダーのときは何もしない
            return
        }
        let ticket = self.tickets[index]
        view.showAddTicketViewAsEdit(ticketModel: ticket)
    }
    
    // 処理を分岐するメソッド
    func checkTableView(_ tableView: UITableView) -> Void{
       
    }
    
    func didDoneDatePicker(selectDate: Date) {
        let dateString = Util.stringFromDateAsNotice(date: selectDate)
        createTaskNotification(id: currentTaskModel.notifications.count + 1, dateString: dateString)
        view.reloadNotificationTable()
    }
    
    func didChengeNotificationActive(isActive: Bool, identifier: String) {
        let notice = currentTaskModel.notifications.filter { $0.identifier == identifier }.first!
        let index = currentTaskModel.notifications.index(of: notice)
        currentTaskModel.notifications[index!].isActive = isActive
    }
    
    private func createTaskNotification(id: Int, dateString: String) {
        let notice = TaskNotificationsModel()
        notice.date = Util.dateFromStringAsNotice(string: dateString)
        notice.id = id
        notice.isActive = true
        notice.identifier = NSUUID().uuidString
        currentTaskModel.notifications.append(notice)
    }
}
