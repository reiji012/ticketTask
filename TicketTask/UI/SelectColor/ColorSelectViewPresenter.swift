//
//  ColorSelectViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

protocol ColorSelectViewPresenterProtocol {
    var numberOfRow: Int { get }
    func content(indexPath: IndexPath) -> TaskColor
    func selectContent(indexPath: IndexPath) -> TaskColor
}

class ColorSelectViewPresenter: ColorSelectViewPresenterProtocol {

    private var view: ColorSelectViewControllerProtocol!
    private var contents: [TaskColor] {
        return [
            .orange,
            .red,
            .yello,
            .blue,
            .purple,
            .green
        ]
    }

    init(view: ColorSelectViewControllerProtocol) {
        self.view = view
    }

    var numberOfRow: Int {
        return contents.count
    }

    func content(indexPath: IndexPath) -> TaskColor {
        return contents[indexPath.row]
    }

    func selectContent(indexPath: IndexPath) -> TaskColor {
        switch indexPath.row {
        case 0:
            return .orange
        case 1:
            return .red
        case 2:
            return .yello
        case 3:
            return .blue
        case 4:
            return .purple
        case 5:
            return .green
        default:
            return .orange
        }
    }
}
