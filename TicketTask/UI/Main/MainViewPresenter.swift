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
    var taskTotalCount: Int { get }
    var weatherIconImage: UIImage? { get }
    func viewDidLoad()
    func getTodayWeatherMaxTemp() -> String
    func getTodayWeatherMinTemp() -> String
    func getDescripiton() -> String
}

class MainViewPresenter: MainViewPresenterProtocol {
    
    var viewController: MainViewControllerProtocol!
    var tasks: [[String:Any]] {
        return taskModel!.tasks!
    }
    var taskTotalCount: Int {
        return taskModel!.tasks!.count
    }
    var weatherIconImage: UIImage?
    
    private var taskModel: TaskModel!
    private var wetherModel: WetherModel!
    private var todayWetherInfo: Dictionary<String,Any>?
    
    init(vc: MainViewControllerProtocol) {
        viewController = vc
        taskModel = TaskModel.sharedManager
        wetherModel = WetherModel.sharedManager
    }
    
    func viewDidLoad() {
        getTaskData()
        setupWetherInfo()
    }
    
    /// タスクデータの取得
    func getTaskData() {
        taskModel?.getTaskData()
    }
    
    /// 天気情報の取得
    func setupWetherInfo() {
        wetherModel?.fetchWetherInfo(callback: {
            self.todayWetherInfo = self.wetherModel?.getWetherTodayInfo()
            guard let viewController = self.viewController else {
                return
            }
            self.weatherIconImage = self.wetherModel.weatherIconImage!
            viewController.setWeatherInfo()
        })
    }
    
    /// 今日の最高気温文字列を取得
    ///
    /// - Returns: 最高気温文字列
    func getTodayWeatherMaxTemp() -> String {
        let maxTempString = todayWetherInfo![WetherInfoConst.TEMP_MAX.rawValue]!
        return "\(maxTempString)"
    }
    
    /// 今日の最低気温文字列を取得
    ///
    /// - Returns: 最低気温文字列
    func getTodayWeatherMinTemp() -> String {
        let minTempString = todayWetherInfo![WetherInfoConst.TEMP_MIN.rawValue]!
        return "\(minTempString)"
    }
    
    /// 天気文字列取得
    ///
    /// - Returns: 天気文字列
    func getDescripiton() -> String {
        let description = todayWetherInfo![WetherInfoConst.DESCRIPTION.rawValue]!
        return "\(description)"
    }
}
