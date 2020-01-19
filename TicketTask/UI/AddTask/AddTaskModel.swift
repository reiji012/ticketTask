//
//  AddTaskModel.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/10/21.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

enum RemindTtpe {
    case none
    case date
    
}

enum TableCellModel {
    case reminder
    case ticket
    
    var cellIdentifier: String {
        switch self {
        case .reminder:
            return "dataCell"
        case .ticket:
            return "cell"
        }
    }
}
