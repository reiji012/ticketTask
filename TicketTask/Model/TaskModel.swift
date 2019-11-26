//
//  TaskModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

class TaskModel: NSObject {
    let id: Int
    var taskTitle: String = ""
    var attri: String = ""
    var color: String = ""
    var icon: String = ""
    var category: String = ""
    var resetType: Int = 0
    var lastResetDate: Date? = nil
    var notifications: [TaskNotificationsModel] = []
    var tickets: [TicketsModel] = []
    
    init(id: Int) {
        self.id = id
    }
}

class TicketsModel: NSObject {
    var identifier: String = ""
    var ticketName: String = ""
    var isCompleted: Bool = false
    var comment: String = ""
    
    override init() {
    }
    
    func initiate(ticketName: String, comment: String) -> TicketsModel {
        let ticket = TicketsModel()
        ticket.ticketName = ticketName
        ticket.isCompleted = false
        ticket.comment = comment
        return ticket
    }
}

class TaskNotificationsModel: NSObject {
    var id: Int = 0
    var identifier: String = ""
    var date: Date? = nil
    var isActive: Bool? = false
}
