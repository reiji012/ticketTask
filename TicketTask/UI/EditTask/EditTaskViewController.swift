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
    
}

class EditTaskViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, EditTaskViewControllerProtocol, ColorSelectViewControllerDelegate, IconSelectViewControllerDelegate {

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
    var ticketTaskColor: TicketTaskColor?
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var taskViewModel: TaskViewModel?
    var mainVC: MainViewController?
    var isEdited: Bool = false
    var pickerView: UIPickerView = UIPickerView()
    
    var currentIconStr: String?
    var currentIcon: UIImage?
    
    let attris: [String] = ["生活", "仕事"]
    
    // MARK: - Initilizer
    static func initiate(taskView: TaskViewProtocol) -> EditTaskViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = EditTaskViewPresenter(view: viewController, taskView: taskView)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ticketTaskColor = TicketTaskColor()
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
        self.taskViewModel?.taskEdited(
            afterTaskName: self.titleTextField.text!,
            afterTaskAttr: "",
            color: presenter.currentColor,
            colorStr: presenter.currentColor.colorString, image: currentIcon!,
            imageStr: currentIconStr!
        )
        
        self.dismiss(animated: true, completion: {
            HUD.flash(.success, onView: self.mainVC!.view, delay: 0.5)
        })
        self.mainVC?.taskEdited(attri: "", color: presenter.currentColor.colorString)
    }
    
    @IBAction func tapIcon(_ sender: Any) {
        let iconSelectVC = IconSelectViewController.initiate(delegate: self, color: presenter.currentColor)
        //表示
        present(iconSelectVC, animated: true, completion: nil)
    }
    
    
    @IBAction func tapColorView(_ sender: Any) {
        let colorCollectionVC = ColorSelectViewController.initiate(delegate: self)
        //表示
        present(colorCollectionVC, animated: true, completion: nil)
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
        currentIcon = self.taskViewModel?.iconImage?.withRenderingMode(.alwaysTemplate)
        currentIconStr = self.taskViewModel?.iconString
        
        setPickerView()
        setColorView()
        setIconImage()
        setGradationColor()
    }
    
    func setGradationColor() {
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
    
    func selectedColor(color: TaskColor) {
        presenter.currentColor = color
        setColorView()
        setIconImage()
        setGradationColor()
    }
    
    func selectedIcon(icon: UIImage, iconStr: String) {
        currentIconStr = iconStr
        currentIcon = icon.withRenderingMode(.alwaysTemplate)
        setIconImage()
    }
    
    
    func setColorView() {
        self.colorView.backgroundColor = presenter.currentColor.gradationColor1
    }
    
    func setIconImage() {
        self.iconImageView.image = currentIcon
        self.iconImageView.tintColor = presenter.currentColor.gradationColor1
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
    
    func setPickerView() {
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // デフォルト設定
        let defoultIndex = self.taskViewModel?.attri == "仕事" ? 1 : 2
        pickerView.selectRow(defoultIndex, inComponent: 0, animated: false)
    }
    
    func changeColor() {
        
    }
    
    
    // 決定ボタン押下
    @objc func done() {
        setGradationColor()
        self.isEdited = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        super.viewWillDisappear(animated)
    }
    
    @objc private func onKeyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardInfo = UIKeyboardInfo(info: userInfo),
            let inputView = view.findFirstResponder(),
            let scrollView = inputView.findSuperView(ofType: UIScrollView.self)
            else { return }
        
        let inputRect = inputView.convert(inputView.bounds, to: scrollView)
        let keyboardRect = scrollView.convert(keyboardInfo.frame, from: nil)
        let offsetY = inputRect.maxY - keyboardRect.minY
        if offsetY > 0 {
            let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + offsetY)
            scrollView.contentOffset = contentOffset
        }
        // 例えば iPhoneX の Portrait 表示だと bottom に34ptほど隙間ができるのでその分を差し引く
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardInfo.frame.height - view.safeAreaInsets.bottom, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func onKeyboardWillHide(_ notification: Notification) {
        guard
            let inputView = view.findFirstResponder(),
            let scrollView = inputView.findSuperView(ofType: UIScrollView.self)
            else { return }
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

}
