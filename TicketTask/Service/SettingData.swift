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
    
    /// 次の日を取得
    ///
    /// - Parameter date: 日付
    /// - Returns: 受け取った日付の翌日
    func getNextDate(date: Date) -> Date {
        // テンプレートから時刻を表示
        let f = DateFormatter()
        f.setTemplate(.date)
        let days = f.string(from: date)
        let day = f.date(from: days)
        return  Calendar.current.date(byAdding: .day, value: 1, to: day!)!
    }
    
    func getToday() -> Date {
        // テンプレートから時刻を表示
        let f = DateFormatter()
        f.setTemplate(.date)
        let days = f.string(from: Date())
        return f.date(from: days)!
    }
    
    /// 日付に応じたリセットタイプ配列を渡す
    ///
    /// - Returns: リセットタイプ
    func checkDate() -> [Int] {
        let date = Date()
        let f = DateFormatter()
        f.setTemplate(.weekDay)
        let week = f.string(from: date)
        var targetType:[Int] = []
        targetType.append(1)
        // 設定「１週間の初めの週」が起動時の日付の週と同じならタイプ２を追加
        if week == "Mounday" {
            targetType.append(2)
        }
        // 現在日時
        // 年月日時分秒をそれぞれ個別に取得
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        // 月初ならタイプ３を追加
        if day == 1 {
            targetType.append(3)
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
