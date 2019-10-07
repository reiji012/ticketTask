//
//  EditTaskViewPresenter.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/03.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol EditTaskViewPresenterProtocol {
    var currentColor: TaskColor { get set }
    var currentIconString: String { get set }
    var currentIcon: UIImage { get }
    func touchSaveButton(afterTaskName: String, afterTaskAttr: String, color: UIColor, colorStr: String, image: UIImage, imageStr: String)
}

class EditTaskViewPresenter: EditTaskViewPresenterProtocol {
    
    
    private var view: EditTaskViewControllerProtocol!
    private var taskView: TaskViewProtocol!
    var currentIconString: String = "" {
        didSet {
            currentIcon = (UIImage(named: currentIconString)?.withRenderingMode(.alwaysTemplate))!
            view.setIconImage(icon: currentIcon)
        }
    }
    
    var currentIcon: UIImage
    var currentColor: TaskColor {
        didSet {
            view.setColorView(color: currentColor.gradationColor1)
        }
    }
    
    init(view: EditTaskViewControllerProtocol, taskView: TaskViewProtocol) {
        self.view = view
        self.taskView = taskView
        currentColor = taskView.presenter.taskViewModel.taskColor!
        currentIcon = taskView.presenter.taskViewModel.iconImage!
        currentIconString = taskView.presenter.taskViewModel.iconString!
    }
    
    func touchSaveButton(afterTaskName: String, afterTaskAttr: String, color: UIColor, colorStr: String, image: UIImage, imageStr: String) {
    }
}
