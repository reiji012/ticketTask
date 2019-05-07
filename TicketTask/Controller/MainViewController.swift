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
        
        //タブのタイトル
        guard let titles: [String] = taskViewModel.taskNames else {
            // タスクが取得できない時はアラートを表示する
            let dialog = UIAlertController(title: "エラー", message: "タスクが取得できません", preferredStyle: .alert)

            dialog.addAction(UIAlertAction(title: "とじる", style: .default, handler: nil))
            // 生成したダイアログを実際に表示します
            self.present(dialog, animated: true, completion: nil)
            return
        } //タブのタイトル
        
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
        for (index, title) in titles.enumerated() {
            //タブになるUIVIewを作る
            taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
            taskView.backgroundColor = .yellow
            taskView.frame = CGRect.init(x: originX + 75, y: 400, width: 350.0, height: 300.0)
            taskView.setLabelText(title: title)

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

