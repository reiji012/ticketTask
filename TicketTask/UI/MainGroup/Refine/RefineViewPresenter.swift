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
    func didSelectTask(indexPath: IndexPath)
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
        view.configureTableView()
        view.setHeaderView(title: uiContent.title, color: uiContent.color)
    }

    func didSelectTask(indexPath: IndexPath) {
        guard let view = view as? RefineViewController, let delegate = view.delegate else {
            return
        }
        let tag = content(indexPath: indexPath).tag!
        delegate.didSelected(tag: tag)
        view.closeView()
    }
}
