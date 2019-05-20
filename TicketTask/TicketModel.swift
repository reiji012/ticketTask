//
//  TicketModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/20.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import RealmSwift

class TicketModel: Object {
    @objc dynamic var taskName: String = ""
    @objc dynamic var ticketName: String = ""
    @objc dynamic var ticketID = 0
    @objc dynamic var isCompleted: Bool = false
}
