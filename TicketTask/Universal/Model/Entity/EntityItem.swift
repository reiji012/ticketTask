//
//  EntityItem.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/14.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import RealmSwift

class EntityItem: Object {
    @objc dynamic var id: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
