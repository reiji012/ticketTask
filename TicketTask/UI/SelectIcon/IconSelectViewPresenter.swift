//
//  File.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol IconSelectViewPresenterProtocol {
    var taskColor: TaskColor { get }
}

class IconSelectViewPresenter: IconSelectViewPresenterProtocol {

    var taskColor: TaskColor

    var view: IconSelectViewControllerProtocol!

    init(view: IconSelectViewControllerProtocol, taskColor: TaskColor) {
        self.view = view
        self.taskColor = taskColor
    }

}
