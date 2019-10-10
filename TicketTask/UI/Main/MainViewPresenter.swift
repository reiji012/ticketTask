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
    func touchAddButton()
    func checkIsTaskEmpty()
    func isLaskTaskView(view: TaskView) -> Bool
    func catchError(error: ValidateError)
}

class MainViewPresenter: MainViewPresenterProtocol, Routable, ErrorAlert {
    
    var viewController: MainViewControllerProtocol!
    var tasks: [[String:Any]] {
        return taskLocalDataModel!.tasks!
    }
    var taskTotalCount: Int {
        return taskLocalDataModel!.tasks!.count
    }
    var weatherIconImage: UIImage?
    
    private var taskLocalDataModel: TaskLocalDataModel!
    private var wetherModel: WetherModel!
    private var todayWetherInfo: Dictionary<String,Any>?
    
    init(vc: MainViewControllerProtocol) {
        viewController = vc
        taskLocalDataModel = TaskLocalDataModel.sharedManager
        wetherModel = WetherModel.sharedManager
    }
    
    func viewDidLoad() {
        getTaskData()
        setupWetherInfo()
    }
    
    func touchAddButton() {
        guard let viewController = viewController as? MainViewController else {
            return
        }
        present(.addTaskViewController, from: viewController, animated: true)
    }
    
    /// タスクデータの取得
    func getTaskData() {
        taskLocalDataModel?.getTaskData()
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
    
    func checkIsTaskEmpty() {
        let isTaskEmpty = self.taskLocalDataModel!.tasks?.isEmpty
        self.viewController?.setTaskEmptyViewState(isHidden: !(isTaskEmpty!))
        if !(isTaskEmpty!) {
            self.viewController?.createAllTaskViews()
        }
    }
    
    /// 最後尾のViewかどうか
    ///
    /// - Parameter view: 確認したいView
    /// - Returns: Bool
    func isLaskTaskView(view: TaskView) -> Bool {
        //どこのタブを表示させたいか計算します
        let taskCount: Int = taskTotalCount
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * 400
        if (maxScrollPoint < Int(viewController.stopPoint)) {
            return true
        } else {
            return false
        }
    }
    
    func catchError(error: ValidateError) {
        guard let viewController = viewController as? MainViewController else {
            return
        }
        createErrorAlert(error: error, massage: "", view: viewController)
    }
}
