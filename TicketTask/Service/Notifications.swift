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
    
    func pushNotificationSet(resetTimeType: Int, taskID: Int) {
        //プッシュ通知のインスタンス
        let notification = UNMutableNotificationContent()
        //通知のタイトル
        notification.title = "push"
        //通知の本文
        notification.body = "これはプッシュ通知です"
        //通知の音
        notification.sound = UNNotificationSound.default
        
        //ナビゲータエリア(ファイルが載っている左)にある画像を指定
        if let path = Bundle.main.path(forResource: "猫", ofType: "png") {
            
            //通知に画像を設定
            notification.attachments = [try! UNNotificationAttachment(identifier: "\(taskID)",
                                                                      url: URL(fileURLWithPath: path), options: nil)]
            
        }
        
        //通知タイミングを指定
        var notificationTime = DateComponents()
        //
        notificationTime.hour = 16
        notificationTime.minute = 11
        let trigger: UNNotificationTrigger
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        //通知のリクエスト
        let request = UNNotificationRequest(identifier: "\(taskID)", content: notification,
                                            trigger: trigger)
        //通知を実装
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}
