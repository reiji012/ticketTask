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
    func didTaskCreated()
    func didAddTicket()
    func setIconImage()
    func setColorView()
    func setGradationColor()
    func initSetState()
}

class AddTaskViewController: UIViewController{
    
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
    var mainVC: MainViewController?
    let navBar = SPFakeBarView.init(style: .stork)
    // Screenの高さ
    var screenHeight:CGFloat!
    // Screenの幅
    var screenWidth:CGFloat!
    
    var presenter: AddTaskViewPresenterProtocol!
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
        self.setColorView()
        self.setIconImage()
        self.setGradationColor()
    }
    
    @IBAction func tapIconView(_ sender: Any) {
        let iconSelectVC = IconSelectViewController.initiate(delegate: self, color: presenter.currentColor)

        //表示
        present(iconSelectVC, animated: true, completion: nil)
    }
    
    @IBAction func tapColorView(_ sender: Any) {
        let colorCollectionVC = ColorSelectViewController.initiate(delegate: self)
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
    
    @IBAction func touchTimerSetButton(_ sender: Any) {
        presenter.selectedResetTypeIndex(index: timerBtm.selectedSegmentIndex)
    }
    // Taskの作成
    @objc func touchCreateButton() {
        presenter.touchCreateButton(taskName: titleTextField.text!)
    }
    
    func setColorView() {
        self.colorView.backgroundColor = presenter.currentColor.gradationColor1
        self.iconImageView.tintColor = presenter.currentColor.gradationColor1
    }
    
    func setIconImage() {
        self.iconImageView.image = UIImage(named: presenter.currentTaskModel.icon)?.withRenderingMode(.alwaysTemplate)
    }
    
    func setGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let color = self.presenter.currentColor
            self.gradientLayer.colors = color.gradationColor
            self.gradientLayer.frame = self.view.bounds
            self.timerBtm.tintColor = color.gradationColor1
            self.ticketAddBtn.setTitleColor(color.gradationColor1, for: .normal)
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
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
}

extension AddTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tickets.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = presenter.tickets[indexPath.row].ticketName
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

extension AddTaskViewController {
    
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

extension AddTaskViewController: ColorSelectViewControllerDelegate {
    func selectedColor(color: TaskColor) {
        presenter.selectedColor(color: color)
    }
}

extension AddTaskViewController: IconSelectViewControllerDelegate {
    func selectedIcon(iconStr: String) {
        presenter.selectedIcon(iconString: iconStr)
        
    }
}
