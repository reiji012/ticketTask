//
//  editTaskViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/27.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import SPStorkController
import SparrowKit
import PKHUD
import RxSwift
import SPFakeBar

protocol EditTaskViewControllerProtocol {
    func setColorView(color: UIColor)
    func setIconImage(icon: UIImage)
    func didSaveTask()
}

class EditTaskViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorSelectViewControllerDelegate, IconSelectViewControllerDelegate {

    let disposeBag = DisposeBag()
    
    private var presenter: EditTaskViewPresenterProtocol!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timerBtn: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let navBar = SPFakeBarView.init(style: .stork)
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var taskViewModel: TaskViewModel?
    var mainVC: MainViewController?
    var isEdited: Bool = false
    var pickerView: UIPickerView = UIPickerView()
    
    var currentIconStr: String?
    var currentIcon: UIImage?
    private var resetType: Int = 0
    
    let attris: [String] = ["生活", "仕事"]
    
    // MARK: - Initilizer
    static func initiate(taskView: TaskViewProtocol) -> EditTaskViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = EditTaskViewPresenter(view: viewController, taskView: taskView)
        let trantisionDelegate = SPStorkTransitioningDelegate()
        viewController.transitioningDelegate = trantisionDelegate
        viewController.modalPresentationStyle = .custom
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = UIColor.white
        
        self.navBar.titleLabel.text = "編集画面"
        self.navBar.leftButton.setTitle("キャンセル", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.touchCanselButton), for: .touchUpInside)
        self.navBar.rightButton.setTitle("保存", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.touchSaveButton), for: .touchUpInside)
        self.navBar.backgroundColor = UIColor.lightGray
        self.view.addSubview(self.navBar)
        
        self.titleTextField.text = taskViewModel?.taskName
        
        self.initStateSet()
        timerBtn.selectedSegmentIndex = presenter.currentResetType
    }
    
    @objc func touchCanselButton() {
        if isEdited {
            self.showAlert()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func touchSaveButton() {
        if (self.titleTextField.text == nil) {
            return
        }
        presenter.touchSaveButton(afterTaskName: self.titleTextField.text!)
    }
    
    @IBAction func touchIconView(_ sender: Any) {
        let iconSelectVC = IconSelectViewController.initiate(delegate: self, color: presenter.currentColor)
        //表示
        present(iconSelectVC, animated: true, completion: nil)
    }
    
    
    @IBAction func touchColorView(_ sender: Any) {
        let colorCollectionVC = ColorSelectViewController.initiate(delegate: self)
        //表示
        present(colorCollectionVC, animated: true, completion: nil)
    }
    
    @IBAction func touchTimerSetButton(_ sender: Any) {
        presenter.touchTimerSetButton(resetTypeIndex: timerBtn.selectedSegmentIndex)
    }
    
    func bind() {
        titleTextField.rx.controlEvent(.editingChanged).asDriver()
            .drive(onNext: { _ in
                self.isEdited = true
            })
            .disposed(by: disposeBag)
        
        titleTextField.rx.controlEvent(.editingDidEndOnExit).asDriver()
            .drive(onNext: { _ in
                self.titleTextField.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    func initStateSet() {
        setColorView(color: presenter!.currentColor.gradationColor1)
        setIconImage(icon: presenter!.currentIcon)
        setGradationColor()
    }
    
    func setGradationColor() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.5, animations: { () -> Void in
                let color = self.presenter.currentColor
                let gradationColor = color.gradationColor
                self.timerBtn.tintColor = color.gradationColor1
                self.gradientLayer.colors = gradationColor
                self.gradientLayer.frame = self.view.bounds
                //            self.gradientLayer.locations = [0.3, 0.7]
                self.view.layer.insertSublayer(self.gradientLayer, at: 0)
            })
        }
    }
    
    func selectedColor(color: TaskColor) {
        presenter.currentColor = color
    }
    
    func selectedIcon(iconStr: String) {
        presenter.currentIconString = iconStr
    }
    
    func showAlert() {
        let alert: UIAlertController = UIAlertController(title: "変更を破棄しますか？", message: "", preferredStyle:  UIAlertController.Style.alert)

        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.dismiss(animated: true, completion: nil)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        // ④ Alertを表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeColor() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension EditTaskViewController: EditTaskViewControllerProtocol {
    func didSaveTask() {
        self.dismiss(animated: true, completion: {
            HUD.flash(.success, onView: self.mainVC!.view, delay: 0.5)
        })
        self.mainVC?.taskEdited(attri: "", color: presenter.currentColor.colorString)
    }
    
    func setIconImage(icon: UIImage) {
        DispatchQueue.main.async {
            self.iconImageView.image = self.presenter.currentIcon
        }
    }
    
    func setColorView(color: UIColor) {
        self.colorView.backgroundColor = color
        self.iconImageView.tintColor = color
        setGradationColor()
    }
}
