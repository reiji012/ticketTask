//
//  MainDelegate.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/11.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol MainViewControllerProtocol {
    var stopPoint: CGFloat { get }
    var scrollWidth: Int { get }
    func setWeatherInfo()
    func setTaskEmptyViewState(isHidden: Bool)
    func createAllTaskViews()
    func didChangeTaskCount(taskCount: Int)
    func showValidateAlert(error: ValidateError)
    func deleteTask(view: TaskView)
    func configureAddTicketView()
}
