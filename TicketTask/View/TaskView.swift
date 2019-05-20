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


class TaskView: UIView{

    @IBOutlet weak var attriImageView: UIImageView!
    @IBOutlet weak var ticketProgressBar: UIProgressView!
    @IBOutlet weak var ticketProgressLabel: UILabel!
    @IBOutlet weak var ticketCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ticketTableView: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    
    var tableViewArray = [UITableViewCell]()
    var taskViewModel: TaskViewModel?

    var defoultWidth: CGFloat?
    var defoultHeight: CGFloat?
    var defoultX: CGFloat?
    var defoultY: CGFloat?
    
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var mainViewController: MainViewController? = nil
    var isShowDetail: Bool = false
    let disposeBag = DisposeBag()

    var gesturView:UIView?
    func setViewModel(task:Dictionary<String, Any>) {
        let taskName = (task["title"] as! String)
        // taskViewModelの取得
        taskViewModel = TaskViewModel(taskName: taskName)
        taskViewModel?.countProgress()
        bind()
        taskViewModel?.getTask(taskName: taskName)
        setLayout()

        self.isUserInteractionEnabled = true
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    @IBAction func tapMenuBtn(_ sender: Any) {
        mainViewController = getMainViewController()

        var isDeleteAction = false
        let actions = [
            PopMenuDefaultAction(title: "タスクを削除", image: nil,color: .red,didSelect: { action in
                isDeleteAction = true
            }),
            PopMenuDefaultAction(title: "タスクの編集", image: nil,color: nil, didSelect: { action in
                print ("hi")
                isDeleteAction = false
            })
        ]
        let menu = PopMenuViewController(sourceView: sender as AnyObject, actions: actions)
        let currentX = menu.contentFrame.origin.x
        menu.contentFrame.origin.x = currentX - 100
        menu.appearance.popMenuColor.backgroundColor = .solid(fill: .lightGray)
        mainViewController!.present(menu, animated: true, completion: nil)
        menu.didDismiss = { selected in
            if isDeleteAction {
                self.showAlert()
            } else {
                print("aa")
            }
            if !selected {
                // When the user tapped outside of the menu
            }
        }
    }
    
    func showAlert() {
        let alert: UIAlertController = UIAlertController(title: "タスクを削除しますか？", message: "", preferredStyle:  UIAlertController.Style.alert)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.mainViewController?.deleteTask(view: self)
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
        
        ticketProgressBar?.setProgress(Float(taskViewModel!.completedProgress!), animated: true)
        
        self.taskViewModel!.progress.subscribe(onNext: { [ticketProgressBar] in
            let convertProgress = Int(($0)*100)
            self.ticketProgressLabel.text = "\(String(convertProgress))%"
            ticketProgressBar?.setProgress(Float($0), animated: true)
        }).disposed(by: disposeBag)
        
        self.taskViewModel!.ticketCout.subscribe(onNext: { [ticketCountLabel] in
            let ticketCount = "チケット：\($0)"
            ticketCountLabel!.text = ticketCount
        }).disposed(by: disposeBag)
        
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if isShowDetail {
            return
        }
        self.changeViewSize()
    }
    
    @objc func tappedHead(_ sender: UITapGestureRecognizer){
        self.changeViewSize()
    }
    
    func setImage() {
        self.attriImageView.image = self.taskViewModel!.attri == "a" ? UIImage(named: "人画像") : UIImage(named: "kabann")
    }
    
    func setLayout() {
        let convertProgress = Int((taskViewModel!.completedProgress!)*100)
        self.ticketProgressLabel.text = "\(String(convertProgress))%"
        // 初期状態では戻るボタンを非表示にする
        backButton.isHidden = true
        ticketTableView.isHidden = true
        // リサイズ用に初期サイズを保存しておく
        self.defoultX = self.frame.origin.x
        self.defoultY = self.frame.origin.y
        
        self.layer.cornerRadius = 30
        // 影の設定
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        self.titleLabel.text = taskViewModel?.taskName
        self.createGesturView()
        self.setGradationColor()
        self.setImage()
    }
    
    /*
     上下のジェスチャー用のVIew作成
     */
    func createGesturView() {
        // create gesturView(subView)
        let currentHeight = self.bounds.size.height / 4
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: currentHeight);
        gesturView = UIView(frame: rect)
        
        // create GesturRecognizer(pan = flick)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        
        // add GesturRecognizer to subview
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tappedHead(_:)))
        gesturView!.addGestureRecognizer(tapGesture)
        gesturView!.addGestureRecognizer(panGestureRecognizer)
        
        self.addSubview(gesturView!)
        gesturView?.isUserInteractionEnabled = false
    }
    
    func changeViewSize() {
        //拡大縮小の処理
        mainViewController = getMainViewController()
        if (self.mainViewController != nil) {
            self.mainViewController?.isShowDetail = !self.isShowDetail
        }
        UIView.animate(withDuration: 0.6, animations: {
            let myBoundWidht: CGFloat = UIScreen.main.bounds.size.width
            let currentWidth = (self.frame.size.width - myBoundWidht)/2
            if self.isShowDetail {
                // 縮小するときの処理
                self.ticketTableView.isHidden = true
                self.frame = CGRect(x:self.defoultX!,y:self.defoultY!,width:self.defoultWidth!,height:self.defoultHeight!)
                self.layer.cornerRadius = 30
                self.backButton.isHidden = true
                self.isShowDetail = false
                self.gesturView?.isUserInteractionEnabled = false
            } else {
                print(self.frame.size.width)
                print(self.bounds.size.width)
                // 拡大するときの処理
                self.defoultHeight = self.frame.size.height
                self.defoultWidth = self.bounds.size.width
                self.defoultX = self.frame.origin.x
                self.ticketTableView.reloadData()
                self.frame.size.height = UIScreen.main.bounds.size.height
                self.frame.size.width = (self.parent?.parent?.frame.size.width)!
                self.frame = CGRect(x:self.frame.origin.x + currentWidth,y:0,width:self.frame.size.width,height:UIScreen.main.bounds.size.height)
                self.layer.cornerRadius = 0
                self.isShowDetail = true
                self.gesturView?.isUserInteractionEnabled = true
            }
        }, completion: { finished in
            self.ticketTableView.isHidden = self.isShowDetail ? false : true
            self.backButton.isHidden = self.isShowDetail ? false : true
            // ViewConrtollerに状態の変更を伝える
        })
    }
    
    func setTableView() {
        self.ticketTableView.estimatedRowHeight = 150
        for _ in taskViewModel!.tickets! {
            self.ticketTableView.register(UINib(nibName: "TichketTableViewCell", bundle: nil), forCellReuseIdentifier: "TichketTableViewCell")
            
            guard let ticketTableViewCell = self.ticketTableView.dequeueReusableCell(withIdentifier: "TichketTableViewCell") as? TichketTableViewCell else {
                return
            }
            self.tableViewArray.append(ticketTableViewCell)
        }
    }

    func deleteRow(indexPath: IndexPath) {
        ticketTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func setGradationColor() {
        let gradationColors = GradationColors()
        self.ticketProgressBar.tintColor = self.taskViewModel?.attri == "a" ? gradationColors.attriABottomColor : gradationColors.attriBBottomColor
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
    
    // フリック時の拡大縮小
    @objc func panGesture(sender:UIPanGestureRecognizer) {
        
        // 左に寄せる分の幅を取得
        
        var tapEndPosX:CGFloat = 0
        var tapEndPosY:CGFloat = 0
        // 指が離れた時（sender.state = .ended）だけ処理をする
        switch sender.state {
        case .ended:
            // タップ開始地点からの移動量を取得
            let position = sender.translation(in: self)
            tapEndPosX = position.x     // x方向の移動量
            tapEndPosY = -position.y    // y方向の移動量（上をプラスと扱うため、符号反転する）
            var panDirection = ""
            // 上下左右のフリック方向を判別する
            // xがプラスの場合（右方向）とマイナスの場合（左方向）で場合分け
            if tapEndPosX > 0 {
                if tapEndPosY > tapEndPosX {
                    panDirection = "up"
                    print("上フリック")
                } else if tapEndPosY < -tapEndPosX {
                    panDirection = "down"
                    print("下フリック")
                }
            } else {
                if tapEndPosY > -tapEndPosX {
                    panDirection = "up"
                    print("上フリック")
                    
                } else if tapEndPosY < tapEndPosX {
                    panDirection = "down"
                    print("下フリック")
                }
            }
            if panDirection == "up" && !self.isShowDetail {
                self.changeViewSize()
            } else if panDirection == "down" && self.isShowDetail {
                self.changeViewSize()
            }
        default:
            break
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



extension UIView {
    public var parent: UIView? {
        get {
            return self.superview
        }
        set(v) {
            if let view = v {
                view.addSubview(self)
            } else {
                self.removeFromSuperview()
            }
        }
    }

}
extension MainViewController: PopMenuViewControllerDelegate {
    
    // This will be called when a menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        // Do stuff here...MainViewController
        print(index)
    }
    
}
