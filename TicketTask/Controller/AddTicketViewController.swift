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
    
    let navBar = SPFakeBarView.init(style: .stork)
    var gradationColors: GradationColors?
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var taskViewModel: TaskViewModel?
    var mainVC: MainViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navBar.titleLabel.text = "チケットの追加"
//        self.navBar.leftButton.setTitle("キャンセル", for: .normal)
//        self.navBar.leftButton.addTarget(self, action: #selector(self.cansel), for: .touchUpInside)
//        self.navBar.rightButton.setTitle("追加", for: .normal)
//        self.navBar.rightButton.addTarget(self, action: #selector(self.addTicket), for: .touchUpInside)
//        self.navBar.backgroundColor = UIColor.lightGray
//        self.view.addSubview(self.navBar)
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

}
