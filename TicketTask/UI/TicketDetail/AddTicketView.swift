//
//  AddTicketView.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/25.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

protocol AddTicketViewDelegate {
    func didTouchCloseButton()
}

class AddTicketView: UIView {

    var delegate: AddTicketViewDelegate?
    
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    
    // MARK: - Initilizer
    static func initiate(taskModel: TaskModel) -> AddTicketView {
        let view = UINib.instantiateInitialView(from: self)
        view.isHidden = true
        return view
    }
    
    @IBAction func touchCloseButton(_ sender: Any) {
        hideView()
    }
    
    func showView() {
        DispatchQueue.main.async {
            self.center.y = 498
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
               self.center.y = 458
                    self.isHidden = false
                    self.alpha = 1
                    self.titleTextField.becomeFirstResponder()
            })
        }
    }
    
    private func hideView() {
        DispatchQueue.main.async {
            self.endEditing(true)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.center.y = 600
                self.alpha = 0
            }, completion: { _ in
                self.isHidden = true
            })
            guard let delegate = self.delegate else {
                return
            }
            delegate.didTouchCloseButton()
        }
        
    }
}
