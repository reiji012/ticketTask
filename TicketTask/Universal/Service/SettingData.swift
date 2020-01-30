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

        //ディクショナリ形式で初期値を指定できる
        userDefaults.register(defaults: [
            Keys.month.rawValue: "1",
            Keys.week.rawValue: "月曜日",
            Keys.day.rawValue: "6",
            Keys.lastResetDate.rawValue: Date(),
            Keys.nextResetDatetoMonth.rawValue: Date()
        ])
    }

    func getNextWeekToMonday(date: Date) -> Date {
        var currentDate = date
        for _ in 0...8 {
            currentDate = getNextDate(date: currentDate)

            let f = DateFormatter()
            f.setTemplate(.weekDay)
            let week = f.string(from: currentDate)
            // 設定「１週間の初めの週」が起動時の日付の週と同じならタイプ２を追加
            if week == "Monday" {
                print(currentDate)
                print(f.string(from: currentDate))
                break
            }
        }
        let f = DateFormatter()
        f.setTemplate(.weekDay)
        return currentDate
    }

    func getMonthFormat(date: Date) -> Date {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!

        // 年月日時分秒のNSComponents
        var comp = calendar.components([.year, .month, .day, .hour, .minute, .second], from: date as Date)

        // 月初の0時0分0秒に設定
        comp.day = 1
        comp.hour = 0
        comp.minute = 0
        comp.second = 0
        // ここでcalendar.date(from: comp)!すれば月初のDateが取得できます

        // その月が何日あるかを計算します
        let range = calendar.range(of: .day, in: .month, for: date as Date)
        let lastDay = range.length

        // ここで月末の日に変えます
        comp.day = lastDay

        // Dateを作成
        return calendar.date(from: comp)!
    }

    func getDayFormat(date: Date) -> Date {
        let dateString = dateFormat(date: date)
        return dateFormatToDate(string: dateString)
    }

    func dateFormat(date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: date)
    }

    func dateFormatToDate(string: String) -> Date {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f.date(from: string)!
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
