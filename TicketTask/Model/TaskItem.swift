//
//  TaskItem.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/20.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import RealmSwift

class TaskItem: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var taskTitle: String = ""
    @objc dynamic var attri: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var category: String = ""
    let tickets = List<TicketModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
