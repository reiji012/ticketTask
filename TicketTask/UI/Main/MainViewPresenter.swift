//
//  MainViewModel.swift
//  TicketTask
//
//  Created by 999-308 on 2019/09/30.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol MainViewPresenterProtocol {
    var tasks: [[String:Any]] { get }
    func viewDidLoad()
}

class MainViewPresenter: MainViewPresenterProtocol {
    
    var viewController: MainViewControllerProtocol!
    var tasks: [[String:Any]] {
        return taskModel!.tasks!
    }
    var todayWetherInfo: Dictionary<String,Any>?
    var weatherIconImage: UIImage?
    
    private var taskModel: TaskModel!
    private var wetherModel: WetherModel!
    
    init(vc: MainViewControllerProtocol) {
        viewController = vc
        taskModel = TaskModel.sharedManager
        wetherModel = WetherModel.sharedManager
    }
    
    func viewDidLoad() {
        getTaskData()
        setupWetherInfo()
    }
    
    func getTaskData() {
        taskModel?.getTaskData()
    }
    
    func setupWetherInfo() {
        wetherModel?.fetchWetherInfo(callback: {
            self.todayWetherInfo = self.wetherModel?.getWetherTodayInfo()
            guard let viewController = self.viewController else {
                return
            }
            self.weatherIconImage = self.wetherModel.weatherIconImage
            viewController.setWeatherInfo()
        })
    }
}
