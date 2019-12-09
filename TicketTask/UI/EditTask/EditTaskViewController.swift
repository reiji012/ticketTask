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
    func setTimeSelectIndex(index: Int)
    func setNavigationBar()
    func reloadNotificationTable()
}

class EditTaskViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorSelectViewControllerDelegate, IconSelectViewControllerDelegate {

    // MARK: - Public Propaty
    let navBar = SPFakeBarView.init(style: .stork)
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var mainVC: MainViewController?
    var isEdited: Bool = false
    var pickerView: UIPickerView = UIPickerView()
    
    var currentIconStr: String?
    var currentIcon: UIImage?
    
    // MARK: - Private Property
    @IBOutlet private weak var addReminderButton: PickerViewKeyboard!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var timerBtn: UISegmentedControl!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var contentsView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var reminderTableView: UITableView!
    
    private var presenter: EditTaskViewPresenterProtocol!
    private var resetType: Int = 0
    private let disposeBag = DisposeBag()
    
    // MARK: - Initilizer
    static func initiate(taskView: TaskViewProtocol) -> EditTaskViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = EditTaskViewPresenter(view: viewController, taskView: taskView)
        let trantisionDelegate = SPStorkTransitioningDelegate()
        viewController.transitioningDelegate = trantisionDelegate
        viewController.modalPresentationStyle = .custom
        return viewController
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        presenter.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = UIColor.white
        self.titleTextField.text = presenter.taskViewModel?.taskName
        self.initStateSet()
        addReminderButton.delegate = self
        
        reminderTableView.dataSource = self
        reminderTableView.delegate = self
    }
    
    // MARK: - Public Function
    func setNavigationBar() {
        self.navBar.titleLabel.text = "編集画面"
        self.navBar.leftButton.setTitle("キャンセル", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.touchCanselButton), for: .touchUpInside)
        self.navBar.rightButton.setTitle("保存", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.touchSaveButton), for: .touchUpInside)
        self.navBar.backgroundColor = UIColor.lightGray
        self.view.addSubview(self.navBar)
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
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
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
    
    func setTimeSelectIndex(index: Int) {
        timerBtn.selectedSegmentIndex = index
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Extension
extension EditTaskViewController: EditTaskViewControllerProtocol {
    func didSaveTask() {
        self.dismiss(animated: true, completion: {
            HUD.flash(.success, onView: self.mainVC!.view, delay: 0.5)
        })
        guard let taskView = presenter.taskView as? TaskView else {
            return
        }
        self.mainVC?.taskEdited(currentTaskView: taskView)
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
    
    func reloadNotificationTable() {
        reminderTableView.reloadData()
    }
}

extension EditTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            presenter.didDeleteNotification(index: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}

// MARK: - Extension UITableViewDataSource
extension EditTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "dataCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NotificationTableCell
        
        let content = presenter.contents(index: indexPath.row)
        cell.dateLabel!.text = Util.stringFromDate(date: content.date, format: "HH:mm")
        cell.switchButton.isOn = content.isActive
        cell.identifier = content.identifier
        cell.delegate = self
        
        return cell
    }
}

extension EditTaskViewController: PickerViewKeyboardDelegate {
    func didDone(sender: PickerViewKeyboard, selectedData: Date) {
        presenter.didDoneDatePicker(selectDate: selectedData)
        self.view.endEditing(true)
    }
    
    func initSelectedRow(sender: PickerViewKeyboard) -> Int {
        return 3
    }
    func didCancel(sender: PickerViewKeyboard) {
        print("canceled")
        self.view.endEditing(true)
    }
}

extension EditTaskViewController: NotificationTableCellDelegate {
    func didTouchSwitchButton(isActive: Bool, identifier: String?) {
        presenter.didChengeNotificationActive(isActive: isActive, identifier: identifier!)
    }
}
