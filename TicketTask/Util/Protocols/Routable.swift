//
//  Routable.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/03.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

enum PresentDestination {
    case addTaskViewController
    case editTaskViewController(taskView: TaskViewProtocol)
    case selectColorViewController(delegate: ColorSelectViewControllerDelegate?)
    case selectIconViewController(delegate: IconSelectViewControllerDelegate?, color: TaskColor)
    
    var viewController: UIViewController {
        switch self {
        case .addTaskViewController:
            return AddTaskViewController.initiate()
        case .editTaskViewController(let taskView):
            return EditTaskViewController.initiate(taskView: taskView)
        case .selectColorViewController(let delegate):
            return ColorSelectViewController.initiate(delegate: delegate!)
        case .selectIconViewController(let delegate, let color):
            return IconSelectViewController.initiate(delegate: delegate!, color: color)
        }
    }
}

enum PushDestination {
    case dummyController
    
    var viewController: UIViewController {
        switch self {
        case .dummyController:
            return UIViewController()
        }
    }
}

protocol Routable {
    func present(_ destination: PresentDestination, from viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func navigationControllerPush(_ destination: PushDestination, from viewController: UIViewController, animated: Bool)
}

extension Routable {
    func present(_ destination: PresentDestination, from viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.present(destination.viewController, animated: animated, completion: completion)
    }
    
    func navigationControllerPush(_ destination: PushDestination, from viewController: UIViewController, animated: Bool) {
        // viewControllerがUINavigationControllerだった時、そのままpushViewControllerを呼ぶ
        if let viewController = viewController as? UINavigationController {
            viewController.pushViewController(destination.viewController, animated: animated)
        } else {
            viewController.navigationController?.pushViewController(destination.viewController, animated: animated)
        }
    }
}
