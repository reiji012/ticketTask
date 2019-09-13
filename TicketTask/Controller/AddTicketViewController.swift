//
//  AddTicketViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/30.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import SPStorkController
import SparrowKit
import SPFakeBar

class AddTicketViewController: UIViewController {
    
    @IBOutlet weak var ticketTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    let navBar = SPFakeBarView.init(style: .stork)
    var ticketTaskColor: TicketTaskColor?
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var taskViewModel: TaskViewModel?
    var mainVC: MainViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ticketTextField.text = ""
    }
    
    func initSetState() {
        
    }
    
    @objc func cansel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addTicket() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        super.viewWillDisappear(animated)
    }

    @IBAction func tapAddBtn(_ sender: Any) {
        if (self.ticketTextField.text == "") {
            return
        }
        mainVC?.addTicket(ticket: self.ticketTextField.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showValidateAlert(error: ValidateError){
        
        var massage = ""
        var title = ""
        switch error {
        case .taskValidError:
            title = "データベースエラー"
            massage = error.rawValue
        case .ticketValidError:
            title = "入力エラー"
            massage = error.rawValue
        default:
            title = "保存に失敗しました"
        }
        
        let alert: UIAlertController = UIAlertController(title: title, message: massage, preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}
