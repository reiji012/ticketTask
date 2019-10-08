//
//  Userdefaults.swift
//  TicketTask
//
//  Created by 999-308 on 2019/09/17.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

enum Keys: String {
    case month = "settiongMonth"
    case week = "settingWeek"
    case day = "setringDay"
    case lastResetDate = "lastResetDate"
    case nextResetDatetoMonth = "nextREsetDate_month"
    case nextResetDatetoWeek = "nextREsetDate_week"
    case nextResetDatetoDay = "nextREsetDate_day"
}

class SettingData {
    
    let userDefaults = UserDefaults.standard
    
    init() {
        
        let tomorrow = Date(timeIntervalSinceNow: 60 * 60 * 24)
        //ディクショナリ形式で初期値を指定できる
        userDefaults.register(defaults: [
            Keys.month.rawValue : "1",
            Keys.week.rawValue : "月曜日",
            Keys.day.rawValue : "6",
            Keys.lastResetDate.rawValue : Date(),
            Keys.nextResetDatetoMonth.rawValue : tomorrow,
        ])
    }
    
    func checkDate() -> [Int] {
//        let calendar = Calendar.current
        let date = Date()
        var targetType:[Int] = []
        if date.weekday == UserDefaults.standard.string(forKey: Keys.week.rawValue) {
            targetType.append(1)
        }
        return targetType
    }
    
    func chengeNotificationMonth(dateStr: String) {
        userDefaults.set(dateStr, forKey: Keys.month.rawValue)
    }
    
    func chengeNotificationWeek(weekStr: String) {
        userDefaults.set(weekStr, forKey: Keys.week.rawValue)
    }
    
    func chengeNotificationHourTime(hourStr: String) {
        userDefaults.set(hourStr, forKey: Keys.day.rawValue)
    }
}

extension Date {
    var weekday: String {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: self)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        return formatter.weekdaySymbols[weekday]
    }
}
