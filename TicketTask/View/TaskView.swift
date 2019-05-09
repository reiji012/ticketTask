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

class TaskView: UIView{

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
    
    var mainViewController: MainViewController? = nil
    
    var isShowDetail: Bool = false
    
    let disposeBag = DisposeBag()
    
    func setViewModel(task:Dictionary<String, Any>) {
        let taskName = (task["title"] as! String)
        // taskViewModelの取得
        taskViewModel = TaskViewModel(taskName: taskName)
        
        mainViewController = getMainViewController()
        setLayout()
        bind()
        bindLayout()
    }
    
    func bindLayout() {
    }
    
    func bind() {
        backButton.rx.tap
            .subscribe { [weak self] _ in
                self?.changeViewSize()
            }
            .disposed(by: disposeBag)
    }
    
    func setLayout() {
        
//        setTableView()
        
        // 初期状態では戻るボタンを非表示にする
        backButton.isHidden = true
        ticketTableView.isHidden = true
        // リサイズ用に初期サイズを保存しておく
        self.defoultHeight = self.frame.size.height
        self.defoultWidth = self.frame.size.width
        self.defoultX = self.frame.origin.x
        self.defoultY = self.frame.origin.y
        
        self.layer.cornerRadius = 30
        // 影の設定
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        titleLabel.text = taskViewModel?.taskName
        
        // create gesturView(subView)
        let currentHeight = self.bounds.size.height / 4
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: currentHeight);
        let gesturView:UIView = UIView(frame: rect)
        
        // create GesturRecognizer(pan = flick)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        
        // add GesturRecognizer to subview
        gesturView.addGestureRecognizer(panGestureRecognizer)
        
        self.addSubview(gesturView)
    }
    
    

    func changeViewSize() {
        UIView.animate(withDuration: 0.5, animations: {
            let myBoundWidht: CGFloat = UIScreen.main.bounds.size.width
            let currentWidth = (self.frame.size.width - myBoundWidht)/2
            if self.isShowDetail {
                // 縮小するときの処理
                self.ticketTableView.isHidden = true
                self.frame = CGRect(x:self.defoultX!,y:self.defoultY!,width:self.defoultWidth!,height:self.defoultHeight!)
                self.layer.cornerRadius = 30
                self.backButton.isHidden = true
                self.isShowDetail = false
            } else {
                // 拡大するときの処理
                self.ticketTableView.reloadData()
                self.frame.size.height = (self.parent?.frame.size.height)!
                self.frame.size.width = (self.parent?.parent?.frame.size.width)!
                self.frame = CGRect(x:self.frame.origin.x + currentWidth,y:0,width:self.frame.size.width,height:self.frame.size.height)
                self.layer.cornerRadius = 0
                let indexPath = IndexPath(row: 0, section: 0)
                self.ticketTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

                self.backButton.isHidden = false
                self.isShowDetail = true
            }
        }, completion: { finished in
            self.ticketTableView.isHidden =             self.isShowDetail
                ? false : true
            // ViewConrtollerに状態の変更を伝える
            if (self.mainViewController != nil) {
                self.mainViewController?.isShowDetail = self.isShowDetail
            }
        })
    }
    
    func setTableView() {
        self.ticketTableView.estimatedRowHeight = 150
        for ticket in taskViewModel!.tickets! {
            self.ticketTableView.register(UINib(nibName: "TichketTableViewCell", bundle: nil), forCellReuseIdentifier: "TichketTableViewCell")
            
            guard let ticketTableViewCell = self.ticketTableView.dequeueReusableCell(withIdentifier: "TichketTableViewCell") as? TichketTableViewCell else {
                return
            }
            self.tableViewArray.append(ticketTableViewCell)
        }
        
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
        //拡大縮小の処理
        
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
