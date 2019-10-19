//
//  Notifications.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/09.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UserNotifications


class Notifications {
    
    func pushNotificationSet(resetTimeType: Int, taskID: Int, taskTitle: String) {
        //プッシュ通知のインスタンス
        let notification = UNMutableNotificationContent()
        //通知のタイトル
        notification.title = "進捗はどうですか？"
        //通知の本文
        notification.body = "\(taskTitle)のチケットを達成しましょう！"
        //通知の音
        notification.sound = UNNotificationSound.default
        
        //通知タイミングを指定
        var notificationTime = DateComponents()
        switch resetTimeType {
        case 0:
            notificationTime.hour = 16
            notificationTime.minute = 11
        case 1:
            notificationTime.hour = 16
            notificationTime.minute = 11
        case 2:
            notificationTime.weekday = 4
        case 3:
            notificationTime.day = 1
        default:
            break
        }
        
        
        let trigger: UNNotificationTrigger
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        //通知のリクエスト
        let request = UNNotificationRequest(identifier: "\(taskID)", content: notification,
                                            trigger: trigger)
        //通知を実装
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}
