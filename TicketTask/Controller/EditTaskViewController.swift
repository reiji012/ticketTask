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

class EditTaskViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, TaskEditDalegate {

    let disposeBag = DisposeBag()
    
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
    
    var currentColorStr: String?
    var currentIconStr: String?
    var currentColor: UIColor?
    var currentIcon: UIImage?
    
    let attris: [String] = ["生活", "仕事"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ticketTaskColor = TicketTaskColor()
        bind()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = UIColor.white
        
        self.navBar.titleLabel.text = "編集画面"
        self.navBar.leftButton.setTitle("キャンセル", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.cansel), for: .touchUpInside)
        self.navBar.rightButton.setTitle("保存", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        self.navBar.backgroundColor = UIColor.lightGray
        self.view.addSubview(self.navBar)
        
        self.titleTextField.text = taskViewModel?.taskName
        
        self.initStateSet()
    }
    
    @objc func cansel() {
        if isEdited {
            self.showAlert()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func save() {
        if (self.titleTextField.text == nil) {
            return
        }
        self.taskViewModel?.taskEdited(
            afterTaskName: self.titleTextField.text!,
            afterTaskAttr: "",
            color: currentColor!,
            colorStr: currentColorStr!, image: currentIcon!,
            imageStr: currentIconStr!
        )
        
        self.dismiss(animated: true, completion:
            {HUD.flash(.success, onView: self.mainVC!.view, delay: 0.5)}
        )
        self.mainVC?.taskEdited(attri: "", color: currentColorStr!)
    }
    
    @IBAction func tapIcon(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Icon", bundle: nil)
        let iconSelectVC = storyboard.instantiateInitialViewController() as! IconSelectViewController
        iconSelectVC.editTaskVC = self
        iconSelectVC.delegate = self
        iconSelectVC.modalPresentationStyle = .overFullScreen
        
        iconSelectVC.preferredContentSize = CGSize(width: 200, height: 200)
        iconSelectVC.popoverPresentationController?.sourceView = view
        // ピヨッと表示する位置の指定
        iconSelectVC.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        // 矢印が出る方向の指定
        iconSelectVC.popoverPresentationController?.permittedArrowDirections = .any
        // デリゲートの設定
        iconSelectVC.popoverPresentationController?.delegate = self
        //表示
        present(iconSelectVC, animated: true, completion: nil)
    }
    
    
    @IBAction func tapColorView(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Color", bundle: nil)
        let colorCollectionVC = storyboard.instantiateInitialViewController() as! ColorSelectViewController
        colorCollectionVC.delegate = self
        colorCollectionVC.editTaskVC = self
        colorCollectionVC.modalPresentationStyle = .overFullScreen
        
        colorCollectionVC.preferredContentSize = CGSize(width: 200, height: 200)
        colorCollectionVC.popoverPresentationController?.sourceView = view
        // ピヨッと表示する位置の指定
        colorCollectionVC.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        // 矢印が出る方向の指定
        colorCollectionVC.popoverPresentationController?.permittedArrowDirections = .any
        // デリゲートの設定
        colorCollectionVC.popoverPresentationController?.delegate = self
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
        currentColor = self.taskViewModel?.taskColor
        currentIconStr = self.taskViewModel?.iconString
        currentColorStr = self.taskViewModel?.colorString
        
        setPickerView()
        setColorView()
        setIconImage()
        setGradationColor()
    }
    
    func setGradationColor() {
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let gradationColor: [CGColor] = self.ticketTaskColor!.getGradation(colorStr: self.currentColorStr!)
            self.timerBtn.tintColor = self.currentColor
            self.gradientLayer.colors = gradationColor
            self.gradientLayer.frame = self.view.bounds
//            self.gradientLayer.locations = [0.3, 0.7]
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    func selectedColor(color: UIColor, colorStr: String) {
        currentColorStr = colorStr
        currentColor = color
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
        self.colorView.backgroundColor = self.currentColor
    }
    
    func setIconImage() {
        self.iconImageView.image = currentIcon
        self.iconImageView.tintColor = currentColor
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
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
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

extension EditTaskViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        /*
         列が複数ある場合は
         if component == 0 {
         } else {
         ...
         }
         こんな感じで分岐が可能
         */
        return attris.count
    }
    
    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /*
         列が複数ある場合は
         if component == 0 {
         } else {
         ...
         }
         こんな感じで分岐が可能
         */
        return attris[row]
    }
    
    /*
     // ドラムロール選択時
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     self.textField.text = list[row]
     }
     */
}
