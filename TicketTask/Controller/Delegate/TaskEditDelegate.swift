//
//  TaskEditDelegate.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/09/01.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol TaskEditDalegate {
    func selectedColor(color: UIColor, colorStr: String)
    func selectedIcon(icon: UIImage, iconStr: String)
}
