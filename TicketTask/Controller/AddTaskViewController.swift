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

class AddTaskViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    

    @IBOutlet weak var scrolView: UIScrollView!
    @IBOutlet weak var taskTicketView: UIView!
    @IBOutlet weak var taskHeadVIew: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ticketTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var attriTextField: UITextField!
    @IBOutlet weak var ticketTextField: UITextField!
    @IBOutlet weak var ticketCellLabel: UILabel!
    
    var pickerView: UIPickerView = UIPickerView()
    let attris: [String] = ["生活", "仕事"]
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var tickets: [String] = []
    var taskViewModel = TaskViewModel()
    var beforeViewAttri: String?
    var gradationColors = GradationColors()
    var mainVC: MainViewController?
    let navBar = SPFakeBarView.init(style: .stork)
    // Screenの高さ
    var screenHeight:CGFloat!
    // Screenの幅
    var screenWidth:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        attriTextField.delegate = self
        ticketTextField.delegate = self
        ticketTableView.delegate = self
        ticketTableView.dataSource = self
        titleTextField.text = ""
        attriTextField.text = attris[0]
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        bindUIs()
        setPickerView()
        
    }

    @IBAction func pushCloseViewBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func bindUIs() {
        setGradationColor()
        
        self.navBar.titleLabel.text = "タスクを追加"
        self.navBar.leftButton.setTitle("キャンセル", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.cansel), for: .touchUpInside)
        self.navBar.rightButton.setTitle("追加", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        self.navBar.backgroundColor = UIColor.lightGray
        self.view.addSubview(self.navBar)
        // 影の設定
//        self.closeViewButton.layer.shadowOpacity = 0.5
//        self.closeViewButton.layer.shadowRadius = 6
//        self.closeViewButton.layer.shadowColor = UIColor.black.cgColor
//        self.closeViewButton.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    @objc func cansel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        if (titleTextField.text == "" || attriTextField.text == "" || tickets.count == 0) {
            showAlert()
            return
        }
        taskViewModel.createTask(taskName: titleTextField.text!, attri: attriTextField.text!, tickets: tickets)
        dismiss(animated: true, completion: {
            guard let vc = self.mainVC else {
                return
            }
            vc.addNewTaskView()
        })
        self.dismiss(animated: true, completion: nil)
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
        
        // インプットビュー設定
        attriTextField.inputView = pickerView
        attriTextField.inputAccessoryView = toolbar
    }
    // 決定ボタン押下
    @objc func done() {
        attriTextField.endEditing(true)
        attriTextField.text = "\(attris[pickerView.selectedRow(inComponent: 0)])"
    }
    
    @IBAction func addTicket(_ sender: Any) {
        guard let text = ticketTextField.text else {
            return
        }
        if text != "" {
            self.tickets.append(ticketTextField.text!)
            ticketTableView.reloadData()
            ticketTextField.text = ""
        }
    }
    
    @IBAction func putCreateTaskBtn(_ sender: Any) {
        
    }
    
    func showAlert(){
        // ① UIAlertControllerクラスのインスタンスを生成
        // タイトル, メッセージ, Alertのスタイルを指定する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        var title = ""
        if titleTextField.text == "" {
            title += "タイトルを入力してください\n"
        }
        if attriTextField.text == "" {
            title += "属性を入力してください\n"
        }
        if tickets.count == 0 {
            title += "チケットを一つ以上追加してください\n"
        }
        let alert: UIAlertController = UIAlertController(title: "入力項目が足りていません", message: title, preferredStyle:  UIAlertController.Style.alert)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
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
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = tickets[indexPath.row]
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tickets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
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

extension AddTaskViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
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
