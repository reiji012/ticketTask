//
//  MainDelegate.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/11.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol MainViewControllerProtocol {
    func setWeatherInfo()
    func setTaskEmptyViewState(isHidden: Bool)
    func createTaskViews()
    func didChangeTaskCount(taskCount: Int)
    func showValidateAlert(error: ValidateError)
}
