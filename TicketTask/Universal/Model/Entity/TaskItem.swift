//
//  TaskItem.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/20.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import RealmSwift

class TaskItem: EntityItem {
    @objc dynamic var taskTitle: String = ""
    @objc dynamic var attri: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var lastResetDate: Date? = nil
    // 0: 無期限, 1: 一日, 2: 一週間, 3: 一月
    @objc dynamic var resetType: Int = 0
    var tickets = List<TicketModel>()
    
    var taskNotifications = List<TaskNotifications>()
}

class TaskNotifications: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var identifier: String = ""
    @objc dynamic var date: Date? = nil
    @objc dynamic var isActive: Bool = false
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
