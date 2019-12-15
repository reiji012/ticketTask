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
    func didAddOrEditTicket()
    func setIconImage()
    func setColorView()
    func setGradationColor()
    func initSetState()
    func reloadNotificationTable()
    func configureAddTicketView()
    func showAddTicketViewAsEdit(ticketModel: TicketsModel)
}

class AddTaskViewController: UIViewController{

    //MARK: - Public Propaty
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var mainVC: MainViewController?
    let navBar = SPFakeBarView.init(style: .stork)
    // Screenの高さ
    var screenHeight:CGFloat!
    // Screenの幅
    var screenWidth:CGFloat!
    
    var presenter: AddTaskViewPresenterProtocol!
    var tableView: UITableView = UITableView()
    var addTicketView: AddTicketView?

    // MARK: - Private Property
    private var currentIcon: UIImage!
    private var currentIconStr: String!
    private var resetType: Int = 0
    
    @IBOutlet weak var addReminderButton: PickerViewKeyboard!
    @IBOutlet private weak var scrolView: UIScrollView!
    @IBOutlet private weak var timerBtm: UISegmentedControl!
    @IBOutlet private weak var taskTicketView: UIView!
    @IBOutlet private weak var taskHeadVIew: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var ticketTableView: UITableView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var reminderTableView: UITableView!
    @IBOutlet weak var ticketAbbButton: UIButton!
    

    // MARK: - Initilizer
    static func initiate() -> AddTaskViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = AddTaskViewPresenter(vc: viewController)
        return viewController
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        titleTextField.delegate = self
        ticketTableView.delegate = self
        ticketTableView.dataSource = self
        reminderTableView.delegate = self
        reminderTableView.dataSource = self
        titleTextField.text = ""
        addReminderButton.delegate = self
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.gestureRecognizers![0].delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Public Function
    func configureAddTicketView() {
        addTicketView = AddTicketView.initiate(taskModel: TaskModel(id: 0))
        addTicketView!.delegate = self
        addTicketView!.frame = self.view.frame
        addTicketView!.defaultCenterY = self.view.center.y + 33
        self.view.addSubview(addTicketView!)
        addTicketView!.isHidden = true
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
        addTicketView?.showView(title: "", memo: "")
        self.navBar.leftButton.isEnabled = false
        self.navBar.rightButton.isEnabled = false
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
    
    @objc func touchAddNotificeButton() {
        
    }
    
    func setColorView() {
        self.colorView.backgroundColor = presenter.currentColor.gradationColor1
        self.iconImageView.tintColor = presenter.currentColor.gradationColor1
    }
    
    func setIconImage() {
        self.iconImageView.image = UIImage(named: presenter.currentTaskModel.icon)?.withRenderingMode(.alwaysTemplate)
    }
    
    func setGradationColor() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let color = self.presenter.currentColor
            self.gradientLayer.colors = color.gradationColor
            self.gradientLayer.frame = self.view.bounds
            self.timerBtm.tintColor = color.gradationColor1
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
            self.ticketAbbButton.backgroundColor = color.gradationColor1
            self.addReminderButton.backgroundColor = color.gradationColor1
        })
    }
}

// MARK: - Extension AddTaskViewControllerProtocol
extension AddTaskViewController: AddTaskViewControllerProtocol {
    func showAddTicketViewAsEdit(ticketModel: TicketsModel) {
        addTicketView?.showView(title: ticketModel.ticketName, memo: ticketModel.comment, identifier: ticketModel.identifier)
    }
    
    func didTaskCreated() {
        dismiss(animated: true, completion: {
            guard let vc = self.mainVC else {
                return
            }
            vc.addNewTaskView()
        })
    }
    
    func didAddOrEditTicket() {
        addTicketView?.hideView()
        ticketTableView.reloadData()
    }
    
    func reloadNotificationTable() {
        reminderTableView.reloadData()
    }
}

// MARK: - Extension UITableViewDataSource
extension AddTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow(tableView: tableView)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = presenter.cellIdentifier(tableView: tableView)
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        // セルに表示する値を設定する
        switch presenter.content {
        case .ticket:
            // 影の設定
            let _cell = cell as? TicketsTableViewCell
            _cell?.titleLabel!.text = presenter.tickets[indexPath.row].ticketName
            _cell?.memoLabel!.text = presenter.tickets[indexPath.row].comment
            return _cell!
        case .reminder:
            let _cell = cell as? NotificationTableCell
            let notice = presenter.currentTaskModel.notifications[indexPath.row]
            _cell!.dateLabel.text = Util.stringFromDate(date: notice.date!, format: "HH:mm")
            _cell!.switchButton.isOn = notice.isActive!
            _cell!.identifier = notice.identifier
            _cell!.delegate = self
            return _cell!
        case .none:
            break
        }
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.removeIndex(indexPath: indexPath, tableView: tableView)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Extension UITableViewDelegate
extension AddTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectedTicketCell(index: indexPath.row, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5 // セルの上部のスペース
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear // 透明にすることでスペースとする
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear // 透明にすることでスペースとする
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

extension AddTaskViewController: PickerViewKeyboardDelegate {
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

extension AddTaskViewController: AddTicketViewDelegate {
    func didTouchCloseButton() {
        self.navBar.leftButton.isEnabled = true
        self.navBar.rightButton.isEnabled = true
    }
    
    func didTouchCheckButton(title: String, memo: String) {
        presenter.touchAddTicketButton(text: title, comment: memo)
    }
    
    func didTouchCheckButtonAsEdit(title: String, memo: String, identifier: String) {
        presenter.touchCheckButtonAsEdit(title: title, memo: memo, identifier: identifier)
    }
    
    
}

extension AddTaskViewController: NotificationTableCellDelegate {
    func didTouchSwitchButton(isActive: Bool, identifier: String?) {
        presenter.didChengeNotificationActive(isActive: isActive, identifier: identifier!)
    }
}

extension AddTaskViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer.view is UITableView {
            return true
        }
        
        return false
    }
}
