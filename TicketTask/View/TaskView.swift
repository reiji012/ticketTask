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

class TaskView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    var taskViewModel: TaskViewModel?

    var defoultWidth: CGFloat?
    var defoultHeight: CGFloat?
    var defoultX: CGFloat?
    var defoultY: CGFloat?
    
    var isShowDetail: Bool = false
    
    func setViewModel(task:Dictionary<String, Any>) {
        let taskName = (task["title"] as! String)
        // taskViewModelの取得
        taskViewModel = TaskViewModel(taskName: taskName)
        
        setLayout()
    }
    
    func setLayout() {
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
        let currentHeight = self.bounds.size.height / 5
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: currentHeight);
        let gesturView:UIView = UIView(frame: rect)
        
        // create GesturRecognizer(pan = flick)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        
        // add GesturRecognizer to subview
        gesturView.addGestureRecognizer(panGestureRecognizer)
        
        self.addSubview(gesturView)
    }

    func changeViewSize() {
        let myBoundWidht: CGFloat = UIScreen.main.bounds.size.width
        let currentWidth = (self.frame.size.width - myBoundWidht)/2
        if isShowDetail {
            self.frame = CGRect(x:self.defoultX!,y:self.defoultY!,width:self.defoultWidth!,height:self.defoultHeight!)
            self.layer.cornerRadius = 30
            self.isShowDetail = false
        } else {
            self.frame.size.height = (self.parent?.frame.size.height)! + 50
            self.frame.size.width = (self.parent?.parent?.frame.size.width)!
            self.frame = CGRect(x:self.frame.origin.x + currentWidth,y:0,width:self.frame.size.width,height:self.frame.size.height)
            self.layer.cornerRadius = 0
            self.isShowDetail = true
        }
    }

    
    
    // フリック時の拡大縮小
    @objc func panGesture(sender:UIPanGestureRecognizer) {
        
        // 左に寄せる分の幅を取得
        
        var tapEndPosX:CGFloat = 0
        var tapEndPosY:CGFloat = 0
        
        // 指が離れた時（sender.state = .ended）だけ処理をする
        UIView.animate(withDuration: 0.5, animations: {
            
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
        })
        
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
