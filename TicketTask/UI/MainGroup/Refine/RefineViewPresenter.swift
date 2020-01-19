//
//  RefineViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/12/19.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

typealias UIContent = (title: String, color: UIColor)

protocol RefineViewPresenterProtocol {
    var numberOfRow: Int { get }
    func content(indexPath: IndexPath) -> TaskViewContentValue
    func viewDidload()
}

class RefineViewPresenter: RefineViewPresenterProtocol {
    
    var numberOfRow: Int {
        return contents.count
    }
    
    func content(indexPath: IndexPath) -> TaskViewContentValue {
        contents[indexPath.row]
    }
    
    var uiContent: UIContent
    
    private var view: RefineViewControllerProtocol
    private var contents: [TaskViewContentValue]
    
    init(view: RefineViewControllerProtocol, contents: [TaskViewContentValue], uiContent: UIContent) {
        self.view = view
        self.contents = contents
        self.uiContent = uiContent
    }
    
    func viewDidload() {
        view.setHeaderView(title: uiContent.title, color: uiContent.color)
    }
    
}
