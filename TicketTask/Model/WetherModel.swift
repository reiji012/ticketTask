//
//  WetherModel.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/11.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import SwiftyJSON

enum WetherInfoConst: String {
    case TEMP_MAX = "temp_max"
    case TEMP_MIN = "temp_min"
    case DESCRIPTION = "description"
    case ICON = "icon"
}

class WetherModel {
    
    private let util = Util()
    private let wetherAPIRequest: WetherAPIRequest = WetherAPIRequest()
    private var wetherData: JSON?
    private var wetherTodayInfo = [String: Any]()

    var weatherIconImage: UIImage?
    
    static var sharedManager: WetherModel = {
        return WetherModel()
    }()
    
    private init() {
        
    }
    
    func fetchWetherInfo(callback: @escaping () -> Void) {
        wetherAPIRequest.fetchWetherData(callback: {
            json,error  in
            if error != nil {
                print(error as Any)
                return
            }
            self.wetherData = json
            let wetherInfo = json!["list"][0]
            self.fetchWeatherIconImage(iconId: wetherInfo["weather"][0]["icon"].rawValue as! String)
            callback()
        })
    }
    
    func fetchWeatherIconImage(iconId: String) {
        self.weatherIconImage = wetherAPIRequest.fetchWeatherIcon(iconId: iconId)
    }
    
    func getWetherTodayInfo() -> Dictionary<String,Any> {
        let wetherInfo = wetherData!["list"][0]
        let maxTemp = util.convertTempRound(temp: wetherInfo["main"]["temp_max"].rawValue as! Double)
        let minTemp = util.convertTempRound(temp: wetherInfo["main"]["temp_min"].rawValue as! Double)
        self.wetherTodayInfo.updateValue(wetherInfo["weather"][0]["description"].rawString()!, forKey: WetherInfoConst.DESCRIPTION.rawValue)
        self.wetherTodayInfo.updateValue(maxTemp, forKey: WetherInfoConst.TEMP_MAX.rawValue)
        self.wetherTodayInfo.updateValue(minTemp, forKey: WetherInfoConst.TEMP_MIN.rawValue)
        return wetherTodayInfo
    }
}
