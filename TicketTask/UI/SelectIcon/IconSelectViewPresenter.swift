//
//  File.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol IconSelectViewPresenterProtocol {
    
}

class IconSelectViewPresenter: IconSelectViewPresenterProtocol{
    
    var view: IconSelectViewControllerProtocol!
    
    init(view: IconSelectViewControllerProtocol) {
        self.view = view
    }
    
}
