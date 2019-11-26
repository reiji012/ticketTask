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
    func didTouchCheckButton(title: String, memo: String)
    func didTouchCheckButtonAsEdit(title: String, memo: String, identifier: String)
}

class AddTicketView: UIView{

    var delegate: AddTicketViewDelegate?
    
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    
    private var isEditMode = false
    private var beforeTitleText = ""
    private var identifier: String?
    
    // MARK: - Initilizer
    static func initiate(taskModel: TaskModel) -> AddTicketView {
        let view = UINib.instantiateInitialView(from: self)
        view.isHidden = true
        return view
    }
    
    @IBAction func touchCloseButton(_ sender: Any) {
        hideView()
    }
    @IBAction func touchCheckButton(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        if isEditMode {
        delegate.didTouchCheckButtonAsEdit(title: titleTextField.text!, memo: memoTextField.text!, identifier: identifier!)
        } else {
            delegate.didTouchCheckButton(title: titleTextField.text!, memo: memoTextField.text!)
        }
    }
    
    func showView(title: String, memo: String, identifier: String? = nil) {
        if let identifier = identifier {
            // identifierがnilでないときは編集として動作させる
            self.identifier = identifier
            isEditMode = true
            beforeTitleText = title
        }
        self.memoTextField.text = memo
        self.titleTextField.text = title
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
    
    func hideView() {
        DispatchQueue.main.async {
            self.endEditing(true)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.center.y = 600
                self.alpha = 0
            }, completion: { _ in
                self.isHidden = true
                self.resetState()
            })
            guard let delegate = self.delegate else {
                return
            }
            delegate.didTouchCloseButton()
        }
    }
    
    private func resetState() {
        self.memoTextField.text = ""
        self.titleTextField.text = ""
        self.identifier = nil
        self.isEditMode = false
    }
}
