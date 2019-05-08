//
//  ViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class MainViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    weak var taskView: TaskView!
    
    var taskViewModel = TaskViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindUI()
    }
    
    func bindUI() {
        //グラデーションの開始色
        let topColor = UIColor(red:0.57, green:0.63, blue:0.96, alpha:1)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.view.bounds
        
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    //一度だけメニュー作成をするためのフラグ
    var didPrepareMenu = false
    
    //タブの横幅
    let tabLabelWidth:CGFloat = 500.0
    
    //viewDidLoad等で処理を行うと
    //scrollViewの正しいサイズが取得出来ません
    override func viewDidLayoutSubviews() {
        createTaskViews()
    }
    
    func createTaskViews() {
        //viewDidLayoutSubviewsはviewDidLoadと違い
        //何度も呼ばれてしまうメソッドなので
        //一度だけメニュー作成を行うようにします
        if didPrepareMenu { return }
        didPrepareMenu = true
        
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
//        タブのタイトル
        let tasks = taskViewModel.tasks
        
        //タブの縦幅(UIScrollViewと一緒にします)
        let tabLabelHeight:CGFloat = scrollView.frame.height
        
        //右端にダミーのUILabelを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let dummyLabelWidth = scrollView.frame.size.width/2 - tabLabelWidth/2
        let headDummyLabel = UIView()
        headDummyLabel.frame = CGRect(x:0, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        scrollView.addSubview(headDummyLabel)
        
        //タブのx座標．
        //ダミーLabel分，はじめからずらしてあげましょう．
        var originX:CGFloat = dummyLabelWidth
        //titlesで定義したタブを1つずつ用意していく
        for (index, task) in tasks.enumerated() {
            //タブになるUIVIewを作る
            taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
            taskView.frame = CGRect.init(x: originX + 75, y: 400, width: 350.0, height: 300.0)
            taskView.setViewModel(task: task as! Dictionary<String, Any>)

            taskView.tag = index
            //scrollViewにぺたっとする
            scrollView.addSubview(taskView)
            
            //次のタブのx座標を用意する
            originX += tabLabelWidth
        }
        
        //左端にダミーのUILabelを置く
        let tailLabel = UILabel()
        tailLabel.frame = CGRect(x:originX, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        scrollView.addSubview(tailLabel)
        
        //ダミーLabel分を足して上げましょう
        originX += dummyLabelWidth
        
        //scrollViewのcontentSizeを，タブ全体のサイズに合わせてあげる(ここ重要！)
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:originX, height:tabLabelHeight)
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.scrollView else { return }
        
        //微妙なスクロール位置でスクロールをやめた場合に
        //ちょうどいいタブをセンターに持ってくるためのアニメーションです
        
        //現在のスクロールの位置(scrollView.contentOffset.x)から
        //どこのタブを表示させたいか計算します
        let index = Int((scrollView.contentOffset.x + tabLabelWidth/2) / tabLabelWidth)
        let x = index * 500
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x:x, y:0)
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        
        //これも上と同様に
        
        let index = Int((scrollView.contentOffset.x + tabLabelWidth/2) / tabLabelWidth)
        let x = index * 500
        UIView.animate(withDuration: 0.5, animations: {
            scrollView.contentOffset = CGPoint(x:x, y:0)
        })
    }
    
}

