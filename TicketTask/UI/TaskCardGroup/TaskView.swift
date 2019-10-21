//
//  TaskView.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PopMenu
import SPStorkController

protocol TaskViewProtocol {
    var presenter: TaskViewPresenterProtocol! { get }
    var isShowDetail: Bool { get set }
    func changeViewSize()
}

class TaskView: UIView, TaskViewProtocol{
    
    // MARK: - Public Propaty
    @IBOutlet weak var buttonTextLabel: UILabel!
    @IBOutlet weak var ticketAddBtn: UIButton!
    @IBOutlet weak var menuTopConst: NSLayoutConstraint!
    @IBOutlet weak var titleTopConst: NSLayoutConstraint!
    @IBOutlet weak var attriImageView: UIImageView!
    @IBOutlet weak var ticketProgressBar: UIProgressView!
    @IBOutlet weak var ticketProgressLabel: UILabel!
    @IBOutlet weak var ticketCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ticketTableView: UITableView!
    @IBOutlet weak var menuBtnLeftConst: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var progressBarWidthConst: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    
    var presenter: TaskViewPresenterProtocol!
    
    var defoultWidth: CGFloat?
    var defoultHeight: CGFloat?
    var defoultX: CGFloat?
    var defoultY: CGFloat?
    var ticketsCount: Int = 0
    
    var topSafeAreaHeight: CGFloat = 0
    
    var layerChangeCount: UInt32 = 0
    var gradientLayer = CAGradientLayer()
    
   
    var mainViewController: MainViewController? = nil
    var isShowDetail: Bool = false
    let disposeBag = DisposeBag()
    var isCenter: Bool = false {
        didSet {
            self.isUserInteractionEnabled = isCenter
        }
    }
    
    // MARK: - Initilizer
    static func initiate(mainViewController: MainViewControllerProtocol, task:TaskModel) -> TaskView {
        let view = UINib.instantiateInitialView(from: self)
        view.presenter = TaskViewPresenter(view: view, mainViewController: mainViewController, task: task)
        
        guard let mainViewController = mainViewController as? MainViewController else {
            return view
        }
        view.setViewModel(task: task, mainVC: mainViewController)
        view.setTableView()
        return view
    }
    
    // MARK: - Public Funciton
    func setViewModel(task:TaskModel, mainVC: MainViewController) {
        self.mainViewController = mainVC

        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touchView(_:)))
        self.addGestureRecognizer(tapGesture)
        print(self.frame.size.width)
        
        // UIImageView の場合
        attriImageView.image = attriImageView.image?.withRenderingMode(.alwaysTemplate)
        attriImageView.tintColor = self.presenter.taskViewModel.taskColor?.gradationColor1
        ticketTableView.register(UINib(nibName: "TicketTableViewCell", bundle: nil), forCellReuseIdentifier: "TicketTableViewCell")
        isCenter = false
    }

    @IBAction func touchMenuButton(_ sender: Any) {

        var selectIndex = 0
        let actions = [
            PopMenuDefaultAction(title: "タスクを削除", image: nil,color: .red,didSelect: { action in
                selectIndex = 1
            }),
            PopMenuDefaultAction(title: "タスクの編集", image: nil,color: nil, didSelect: { action in
                selectIndex = 2
            })
        ]
        let menu = PopMenuViewController(sourceView: sender as AnyObject, actions: actions)
        let currentX = menu.contentFrame.origin.x
        menu.contentFrame.origin.x = currentX - 100
        menu.appearance.popMenuColor.backgroundColor = .solid(fill: .white)
        mainViewController!.present(menu, animated: true, completion: nil)
        menu.didDismiss = { selected in
            switch selectIndex {
            case 1:
                self.touchDeleteButton()
            case 2:
                self.touchEditButton()
            default:
                break
            }
            if !selected {
                // When the user tapped outside of the menu
            }
        }
    }
    
    @objc func touchView(_ sender: UITapGestureRecognizer){
        presenter.touchView()
    }
    
    func touchEditButton() {
        let editViewController = EditTaskViewController.initiate(taskView: self)
        let trantisionDelegate = SPStorkTransitioningDelegate()
        editViewController.transitioningDelegate = trantisionDelegate
        editViewController.modalPresentationStyle = .custom
        self.mainViewController?.showEditView(editTaskVC: editViewController, taskVM: self.presenter.taskViewModel)
    }
    
    func touchDeleteButton() {
        let alert: UIAlertController = UIAlertController(title: "タスクを削除しますか？", message: "", preferredStyle:  UIAlertController.Style.alert)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.presenter.deleteTask()
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
        mainViewController!.present(alert, animated: true, completion: nil)
    }
    
    func bind() {
        self.backButton.rx.tap
            .subscribe { [weak self] _ in
                self?.changeViewSize()
            }
            .disposed(by: disposeBag)
        
        self.ticketAddBtn.rx.tap
            .subscribe { [weak self] _ in
                self?.touchAddTicketButton()
            }
            .disposed(by: disposeBag)
        
        ticketProgressBar?.setProgress(Float(self.presenter.taskViewModel.completedProgress!), animated: true)
        
        self.presenter.taskViewModel.progress.subscribe(onNext: { [ticketProgressBar] in
            let convertProgress = Int(($0)*100)
            self.ticketProgressLabel.text = "\(String(convertProgress))%"
            ticketProgressBar?.setProgress(Float($0), animated: true)
        }).disposed(by: disposeBag)
        
        self.presenter.taskViewModel.ticketCout.subscribe(onNext: { [ticketCountLabel] in
            self.ticketsCount = $0
            let ticketCount = "チケット：\($0)"
            ticketCountLabel!.text = ticketCount
        }).disposed(by: disposeBag)
        
        self.presenter.taskViewModel.taskTitle.subscribe(onNext: { [titleLabel] in
            let taskTitle = $0
            titleLabel!.text = taskTitle
        }).disposed(by: disposeBag)
        
        self.presenter.taskViewModel.taskAttri.subscribe(onNext: { [attriImageView] in
            _ = $0
            attriImageView!.image = self.presenter.taskViewModel.iconImage
        }).disposed(by: disposeBag)
        
    }

    
    func setImage() {
        self.attriImageView.image = self.presenter.taskViewModel.iconImage?.withRenderingMode(.alwaysTemplate)
    }
    
    func touchAddTicketButton() {
        
        //alertの表示文言
        let alertController: UIAlertController = UIAlertController(title: "チケットの追加", message: "", preferredStyle: .alert)
        
        //キャンセルボタンを押す
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel) { action -> Void in
            // キャンセルを押した時の処理
        }
        alertController.addAction(cancelAction)
        
        let addAction: UIAlertAction = UIAlertAction(title: "追加", style: .default) { action -> Void in
            guard let text = alertController.textFields?.first!.text else {
                return
            }
            //追加ボタンを押した時の処理
            self.ticketTableView.reloadData()
            self.presenter.didTouchAddTicketButton(ticket: text)
        }
        
        alertController.addAction(addAction)
        alertController.addTextField { textField -> Void in
            textField.placeholder = "追加するチケット"
        }
        mainViewController!.present(alertController, animated: true, completion: nil)
    }
    
    func setLayout() {
        self.ticketAddBtn.isHidden = true
        self.buttonTextLabel.isHidden = true
        let convertProgress = Int((self.presenter.taskViewModel.completedProgress!)*100)
        self.ticketProgressLabel.text = "\(String(convertProgress))%"
        // 初期状態では戻るボタンを非表示にする
        backButton.isHidden = true
        ticketTableView.isHidden = true
        // リサイズ用に初期サイズを保存しておく
        self.defoultX = self.frame.origin.x
        self.defoultY = self.frame.origin.y
        
        self.layer.cornerRadius = 30
        // 影の設定
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 5)
        
        self.progressBarWidthConst.constant = presenter.progressBarWidthConst
        self.menuBtnLeftConst.constant = presenter.menuLeftConst
        
        self.titleLabel.text = self.presenter.taskViewModel.taskName
        self.setButtonLayout()
        self.setGradationColor(color: presenter.currentColor)
        self.setImage()
        self.ticketTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func changeViewSize() {
        //拡大縮小の処理
        if (self.mainViewController != nil) {
            self.mainViewController?.isShowDetail = !self.isShowDetail
        }
        let myBoundWidht: CGFloat = UIScreen.main.bounds.size.width
        let currentWidth = (self.frame.size.width - myBoundWidht)/2
        if isShowDetail {
            // 縮小するときの処理
            self.menuTopConst.constant = 50
            self.titleTopConst.constant = 160
            self.menuBtnLeftConst.constant -= ((myBoundWidht - self.defoultWidth!))
            self.progressBarWidthConst.constant -= (myBoundWidht - self.defoultWidth!)
            
        } else {
            // 拡大するときの処理
            if 0 < self.mainViewController!.topSafeAreaHeight() {
                self.menuTopConst.constant = (20 + self.mainViewController!.topSafeAreaHeight())
            } else {
               self.menuTopConst.constant = 40
            }
            self.titleTopConst.constant = 220
            self.menuBtnLeftConst.constant += ((myBoundWidht - self.bounds.size.width))
            self.progressBarWidthConst.constant += (myBoundWidht - self.bounds.size.width)
        }
        UIView.animate(withDuration: 0.6, delay: 0.0, animations: {
            
            self.menuButton.layoutIfNeeded()
            self.layoutIfNeeded()
            self.ticketProgressBar.layoutIfNeeded()
            
            self.ticketAddBtn.isHidden = self.isShowDetail
            self.buttonTextLabel.isHidden = self.isShowDetail
            self.layer.cornerRadius = self.isShowDetail ? 30 : 0
            self.mainViewController!.changeTabbarStatus(isFront: self.isShowDetail)
            if self.isShowDetail {
                // 縮小するときの処理
                self.ticketTableView.isHidden = true
                self.frame = CGRect(x:self.defoultX!,y:self.defoultY!,width:self.defoultWidth!,height:self.defoultHeight!)
                
                self.backButton.isHidden = true
                
            } else {
                // 拡大するときの処理
                self.defoultHeight = self.frame.size.height
                self.defoultWidth = self.bounds.size.width
                self.defoultX = self.frame.origin.x
                self.ticketTableView.reloadData()
                self.frame = CGRect(x:self.frame.origin.x + currentWidth,y:0,width:(self.parent?.parent?.frame.size.width)!,height:UIScreen.main.bounds.size.height)

            }
        }, completion: { finished in
            self.isShowDetail = !self.isShowDetail
            self.ticketTableView.isHidden = !self.isShowDetail
            self.backButton.isHidden = !self.isShowDetail
            // ViewConrtollerに状態の変更を伝える
        })
    }
    
    func setTableView() {
        self.ticketTableView.delegate = self
        self.ticketTableView.dataSource = self
//        self.ticketTableView.estimatedRowHeight = 150
        self.ticketTableView.reloadData()
    }

    func deleteRow(indexPath: IndexPath) {
        ticketTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func setButtonLayout() {
        let view = UIView()
        view.bounds = ticketAddBtn.bounds
        self.ticketAddBtn.layer.shadowOpacity = 0.5
        self.ticketAddBtn.layer.shadowRadius = 12
        self.ticketAddBtn.layer.shadowColor = UIColor.black.cgColor
        self.ticketAddBtn.layer.shadowOffset = CGSize(width: 3, height: 4)
        
    }
    
    func setGradationColor(color: TaskColor) {
        self.ticketProgressBar.tintColor = color.gradationColor1
        self.attriImageView.image = self.presenter.taskViewModel.iconImage
        self.attriImageView.tintColor = color.gradationColor1
        gradientLayer.colors = color.gradationColor
        gradientLayer.bounds = self.ticketAddBtn.bounds
        gradientLayer.frame.origin.x = 0
        gradientLayer.frame.origin.y = 0
        self.ticketAddBtn.layer.insertSublayer(gradientLayer, at: 0)
        self.ticketAddBtn.setTitle("＋", for: .normal)
        ticketTableView.reloadData()
    }

    func getMainViewController() -> MainViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            
            return topViewControlelr as? MainViewController
        } else {
            return nil
        }
    }
    
    // 親ビュー (parent) に対して上下左右マージンゼロの指定をする
    func applyAutoLayoutMatchParent(parent: UIView, margin: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .left, .right, .bottom]
        let constraints = attributes.map { (attribute) -> NSLayoutConstraint in
            return NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: .equal,
                toItem: parent,
                attribute: attribute,
                multiplier: 1.0,
                constant: margin
            )
        }
        parent.addConstraints(constraints)
    }
}

// MARK: - Extention PopMenuViewControllerDelegate
extension MainViewController: PopMenuViewControllerDelegate {
    
    // This will be called when a menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        // Do stuff here...MainViewController
        print(index)
    }
    
}

// MARK: - Extention UITableViewDelegate
extension TaskView: UITableViewDelegate {
    
}

// MARK: - Extention UITableViewDataSource
extension TaskView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.presenter.taskViewModel.tickets?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell") as? TicketTableViewCell {
            cell.taskViewModel = self.presenter.taskViewModel
            var ticketName = ""
            var isCompleted: Bool?
            for (index, ticket) in (self.presenter.taskViewModel.tickets!).enumerated() {
                if index == indexPath.row {
                    ticketName = ticket.ticketName
                    isCompleted = ticket.isCompleted
                }
            }
            cell.isCompleted = isCompleted!
            cell.checkBoxLabel.text = isCompleted! ? "✔️" : ""
            cell.ticketNameLabel.text = ticketName
            return cell
        }
        
        return UITableViewCell()
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ticketName = Array(self.presenter.taskViewModel.tickets!.map({$0.ticketName}))[indexPath.row]
            self.presenter.taskViewModel.actionType = .ticketDelete
            for (index, ticket) in (self.presenter.taskViewModel.tickets?.enumerated())! {
                if ticket.ticketName == ticketName {
                    self.presenter.taskViewModel.tickets?.remove(at: index)
                }
            }
            self.ticketTableView.reloadData()
        }
    }
    
}
