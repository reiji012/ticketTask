//
//  MainViewModel.swift
//  TicketTask
//
//  Created by 999-308 on 2019/12/19.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

enum ButtonContents {
    case completed
    case umcompleted
}

class TaskViewContentValue {
    var taskModel: TaskModel?
    var tag: Int?
}
