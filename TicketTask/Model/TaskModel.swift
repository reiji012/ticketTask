//
//  TaskModel.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TaskModel: NSObject {

    var tasks :[ String:String] = [:]
    
    func createArray() {
        for i in 0..<10 {
            let attri = i % 2 == 0 ? "a" : "b"
            tasks["title\(i)"] = attri
            print(self.tasks as Any)
        }
    }
}
