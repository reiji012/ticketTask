//
//  SplashViewController.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/29.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

protocol SplashViewControllerProtocol {
    
}

class SplashViewController: UIViewController, SplashViewControllerProtocol {

    private var presenter: SplashViewPresenterProtocol!
    
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SplashViewPresente(view: self)
        // Do any additional setup after loading the view.
        
        self.gradientLayer.colors = TaskColor.orange.gradationColor
        self.gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
