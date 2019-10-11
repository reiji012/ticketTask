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
    var lastResetDate: Date? = nil
    
    var tickets: [TicketsModel] = []
    
    init(id: Int) {
        self.id = id
    }
}

class TicketsModel: NSObject {
    var ticketName: String = ""
    var isCompleted: Bool = false
    
    override init() {
    }
    
    func initiate(ticketName: String) -> TicketsModel {
        var ticket = TicketsModel()
        ticket.ticketName = ticketName
        ticket.isCompleted = false
        return ticket
    }
}
