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

class MainViewController: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    // ViewModelの取得
    var taskViewModel = TaskViewModel()
    
    var tableViewArray = [UITableViewCell]()
    var taskViewIndex: Int?
    var isShowDetail: Bool = false {
        didSet(value) {
            self.scrollView.isScrollEnabled = value
        }
    }
    weak var taskView: TaskView!
    //TaskViewの横幅
    let taskViewWidth:CGFloat = 500.0
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        // Do any additional setup after loading the view.
        bindUI()
        createTaskViews()
    }
    func bindUI() {
        //グラデーションの作成
        let topColor = UIColor(red:0.47, green:0.73, blue:0.96, alpha:1)
        let bottomColor = UIColor(red:0.34, green:0.54, blue:0.94, alpha:1)
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }


    override func viewDidLayoutSubviews() {
        
    }
    
    func createTaskViews() {
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
//        タブのタイトル
        let tasks = taskViewModel.tasks
        
        //タブの縦幅(UIScrollViewと一緒にします)
        let tabLabelHeight:CGFloat = scrollView.frame.height
        
        //右端にダミーのUILabelを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let dummyLabelWidth = scrollView.frame.size.width/2 - taskViewWidth/2
        let headDummyLabel = UIView()
        headDummyLabel.frame = CGRect(x:0, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        scrollView.addSubview(headDummyLabel)
        
        //タブのx座標．
        //ダミーLabel分，はじめからずらしてあげましょう．
        var originX:CGFloat = dummyLabelWidth
        
        // VIewを設置する高さを計算する
        let mainScreenHeight: CGFloat = UIScreen.main.bounds.size.height
        let currentY = mainScreenHeight - 450
        //titlesで定義したタブを1つずつ用意していく
        for (index, task) in tasks!.enumerated() {
            //タブになるUIVIewを作る
            taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
            taskView.frame = CGRect.init(x: originX + 75, y: currentY, width: 350.0, height: 300.0)
            taskView.setViewModel(task: task)
            taskView.setTableView()

            taskView.ticketTableView!.delegate = self
            taskView.ticketTableView!.dataSource = self
            
            taskView.tag = index + 1
            
            scrollView.addSubview(taskView)
            //次のタブのx座標を用意する
            originX += taskViewWidth
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = (self.taskViewIndex != nil) ? self.taskViewIndex! : 1
        let currentTaskView = self.view.viewWithTag(index) as! TaskView
        return currentTaskView.tableViewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTaskView: TaskView
        if self.taskViewIndex == nil {
            currentTaskView = self.view.viewWithTag(1) as! TaskView
        } else {
            currentTaskView = self.view.viewWithTag(taskViewIndex!) as! TaskView
        }
        let tableViewCell = currentTaskView.tableViewArray[indexPath.row]
        print(indexPath.row)
        if tableViewCell is TichketTableViewCell {
            let currentTableViewCell: TichketTableViewCell = tableViewCell as! TichketTableViewCell
            var ticketName = ""
            var isCompleted: Bool?
            for (index, ticket) in (currentTaskView.taskViewModel?.tickets!.keys)!.enumerated() {
                if index == indexPath.row {
                    ticketName = ticket
                    isCompleted = (currentTaskView.taskViewModel?.tickets![ticketName])!
                }
            }
            currentTableViewCell.isCompleted = isCompleted!
            currentTableViewCell.checkBoxLabel.text = isCompleted! ? "✔️" : ""
            currentTableViewCell.ticketName.text = ticketName
            return currentTableViewCell
        }
        
        return UITableViewCell()
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.scrollView else { return }
        
        //微妙なスクロール位置でスクロールをやめた場合に
        //ちょうどいいタブをセンターに持ってくるためのアニメーションです
        
        //現在のスクロールの位置(scrollView.contentOffset.x)から
        //どこのタブを表示させたいか計算します
        let index = Int((scrollView.contentOffset.x + taskViewWidth/2) / taskViewWidth)
        let x = index * 500
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x:x, y:0)
            self.taskViewIndex = x + 1
            print(x)
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        
        //これも上と同様に
        
        let index = Int((scrollView.contentOffset.x + taskViewWidth/2) / taskViewWidth)
        let x = index * 500
        UIView.animate(withDuration: 0.5, animations: {
            scrollView.contentOffset = CGPoint(x:x, y:0)
            self.taskViewIndex = (x / 500) + 1
            print(x)
        })
    }
    
}

