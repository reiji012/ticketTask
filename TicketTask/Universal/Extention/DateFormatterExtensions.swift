//
//  DateFormatterExtensions.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/09.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

extension DateFormatter {
    // テンプレートの定義(例)
    enum Template: String {
        case day = "d"
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case full = "yy/MM/dd/HH" // 2017/1/1 12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case weekDay = "EEEE" // 日曜日
    }

    func setTemplate(_ template: Template) {
        // optionsは拡張用の引数だが使用されていないため常に0
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
    }
}
