//
//  addTaskViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/10.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {

    @IBOutlet weak var closeViewButton: UIButton!
    
    var gradientLayer: CAGradientLayer = CAGradientLayer()

    var taskViewModel: TaskViewModel?
    var beforeViewAttri: String?
    var gradationColors = GradationColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeViewButton.backgroundColor = self.beforeViewAttri == "a" ? gradationColors.attriATopColor : gradationColors.attriBTopColor
        bindUIs()
    }
    
    
    
    @IBAction func pushCloseViewBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func bindUIs() {
        // 影の設定
        self.closeViewButton.layer.shadowOpacity = 0.5
        self.closeViewButton.layer.shadowRadius = 6
        self.closeViewButton.layer.shadowColor = UIColor.black.cgColor
        self.closeViewButton.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    func setGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let topColor = self.gradationColors.addViewTopColor
            let bottomColor = self.gradationColors.addViewBottomColor
            let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
            self.gradientLayer.colors = gradientColors
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }

}
