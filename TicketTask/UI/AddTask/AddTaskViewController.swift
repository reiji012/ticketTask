//
//  addTaskViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/10.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import SPStorkController
import SparrowKit
import SPFakeBar

protocol AddTaskViewControllerProtocol {
    func showValidateAlert(title: String, massage: String)
    func didTaskCreated()
    func didAddTicket()
}

class AddTaskViewController: UIViewController, UIPopoverPresentationControllerDelegate, TaskEditDalegate{
    
    var tableView: UITableView = UITableView()
    @IBOutlet weak var scrolView: UIScrollView!
    @IBOutlet weak var timerBtm: UISegmentedControl!
    @IBOutlet weak var taskTicketView: UIView!
    @IBOutlet weak var taskHeadVIew: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ticketTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var ticketTextField: UITextField!
    @IBOutlet weak var ticketCellLabel: UILabel!
    @IBOutlet weak var ticketAddBtn: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    var pickerView: UIPickerView = UIPickerView()
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var beforeViewAttri: String?
    var ticketTaskColor = TicketTaskColor()
    var mainVC: MainViewController?
    let navBar = SPFakeBarView.init(style: .stork)
    // Screenの高さ
    var screenHeight:CGFloat!
    // Screenの幅
    var screenWidth:CGFloat!
    
    var presenter: AddTaskViewPresenterProtocol!
    private var currentColor: UIColor!
    private var currentColorStr: String!
    private var currentIcon: UIImage!
    private var currentIconStr: String!
    private var resetType: Int = 0
    
    // MARK: - Initilizer
    static func initiate() -> AddTaskViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = AddTaskViewPresenter(vc: viewController)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AddTaskViewPresenter(vc: self)
        presenter.viewDidLoad()
        titleTextField.delegate = self
        ticketTextField.delegate = self
        ticketTableView.delegate = self
        ticketTableView.dataSource = self
        titleTextField.text = ""
        ticketTextField.text = ""
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        initSetState()
        bindUIs()
        
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
    
    @IBAction func tapIconView(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Icon", bundle: nil)
        let iconSelectVC = storyboard.instantiateInitialViewController() as! IconSelectViewController
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
    
    @IBAction func touchAddTicketButton(_ sender: Any) {
        let text = ticketTextField.text
        if text == "" {
            return
        }
        presenter.touchAddTicketButton(text: text!)
    }
    
    @objc func touchCanselButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Taskの作成
    @objc func touchCreateButton() {
        presenter.touchCreateButton(taskName: titleTextField.text!,
                                    attri: "",
                                    colorStr: currentColorStr,
                                    iconStr: currentIconStr,
                                    tickets: presenter.tickets,
                                    resetType: self.resetType)
    }
    
    func bindUIs() {
        setGradationColor()
        
        self.navBar.titleLabel.text = "タスクを追加"
        self.navBar.leftButton.setTitle("キャンセル", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.touchCanselButton), for: .touchUpInside)
        self.navBar.rightButton.setTitle("追加", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.touchCreateButton), for: .touchUpInside)
        self.navBar.backgroundColor = UIColor.lightGray
        self.view.addSubview(self.navBar)
    }
    
    func initSetState() {
        let iconStr = "icon-0"
        self.currentColor = self.ticketTaskColor.ticketTaskOrange_1
        self.currentColorStr = ticketTaskColor.ORANGE
        self.currentIcon = UIImage(named: iconStr)?.withRenderingMode(.alwaysTemplate)
        self.currentIconStr = iconStr
        self.setColorView()
        self.setIconImage()
        self.setGradationColor()
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
    
    func setGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let gradientColors = self.ticketTaskColor.getGradation(colorStr: self.currentColorStr)
            self.gradientLayer.colors = gradientColors
            self.gradientLayer.frame = self.view.bounds
            self.timerBtm.tintColor = self.currentColor
            self.ticketAddBtn.setTitleColor(self.currentColor, for: .normal)
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
}

extension AddTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tickets.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = presenter.tickets[indexPath.row]
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.removeTicket(index: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension AddTaskViewController: UITableViewDelegate {
    
}

extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        print("touchesBegan")
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
        print("touchesMoved")
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
        print("touchesEnded")
    }
}

extension AddTaskViewController: AddTaskViewControllerProtocol {
    func didTaskCreated() {
        dismiss(animated: true, completion: {
            guard let vc = self.mainVC else {
                return
            }
            vc.addNewTaskView()
        })
    }
    
    func didAddTicket() {
        ticketTableView.reloadData()
        ticketTextField.text = ""
    }
    
    func showValidateAlert(title: String, massage: String) {
        
        
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

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
