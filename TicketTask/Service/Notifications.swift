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
    
    func pushNotificationSet(resetTimeType: Int, taskID: Int, taskTitle: String, notificationModel: TaskNotificationsModel) {
        //プッシュ通知のインスタンス
        let notification = UNMutableNotificationContent()
        //通知のタイトル
        notification.title = "進捗はどうですか？"
        //通知の本文
        notification.body = "\(taskTitle)のチケットを達成しましょう！"
        //通知の音
        notification.sound = UNNotificationSound.default
        let url = "https://google.com"
        notification.userInfo = ["schemeURL": url]
        
        //通知タイミングを指定
        
        let dateComponents = splitStringForDate(date: notificationModel.date!)
        var notificationTime = DateComponents()
        switch resetTimeType {
        case 0:
            // 無期限
            notificationTime.hour = dateComponents.hour
            notificationTime.minute = dateComponents.minute
        case 1:
            // 毎日
            notificationTime.hour = dateComponents.hour
            notificationTime.minute = dateComponents.minute
        case 2:
            // 毎週
            notificationTime.weekday = 4
            notificationTime.hour = dateComponents.hour
            notificationTime.minute = dateComponents.minute
        case 3:
            // 毎月
            notificationTime.day = 1
            notificationTime.hour = dateComponents.hour
            notificationTime.minute = dateComponents.minute
        default:
            break
        }
        
        
        let trigger: UNNotificationTrigger
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        //通知のリクエスト
        let request = UNNotificationRequest(identifier: notificationModel.identifier, content: notification,
                                            trigger: trigger)
        //通知を実装
        if notificationModel.isActive! {
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(taskID)_\(notificationModel.id)"])
        }
    }
    
    func splitStringForDate(date: Date) -> (hour: Int, minute: Int) {
        // 一度Stringに変換して、HHとmmで分割。その後それぞれをIntに変換
        var hour: Int = 0
        var minute: Int = 0
        let dateString = Util.stringFromDateAsNotice(date: date)
        
        let pattern = "([^/]+):([^/]+)"
        hour = Int(dateString.capture(pattern: pattern, group: 1)!)!
        minute = Int(dateString.capture(pattern: pattern, group: 2)!)!
        
        return (hour: hour, minute: minute)
    }
}
