//
//  ViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
//import RxSwift
//import RxRelay
//import RxCocoa

class MainViewController: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    // ViewModelの取得
    var taskViewModel = TaskViewModel()
    
    var centerViewAttri: String?
    var tableViewArray = [UITableViewCell]()
    var taskViewIndex: Int?
    var isShowDetail: Bool = false {
        didSet(value) {
            self.scrollView.isScrollEnabled = value
        }
    }
    weak var taskView: TaskView!
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    //TaskViewの横幅
    let taskViewWidth:CGFloat = 400.0
    let currentWidth: Int = 400
    var stopPoint: CGFloat = 0.0
    
    var gradationColors: GradationColors?
    
    @IBOutlet weak var taskAddButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        // Do any additional setup after loading the view.
        bindUI()
        createTaskViews()
    }
    func bindUI() {
        gradationColors = GradationColors()
        // 影の設定
        self.taskAddButton.layer.shadowOpacity = 0.5
        self.taskAddButton.layer.shadowRadius = 12
        self.taskAddButton.layer.shadowColor = UIColor.black.cgColor
        self.taskAddButton.layer.shadowOffset = CGSize(width: 3, height: 4)
    }


    func setGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let topColor = self.centerViewAttri! == "a" ? self.gradationColors?.attriATopColor : self.gradationColors?.attriBTopColor
            let bottomColor = self.centerViewAttri! == "a" ? self.gradationColors?.attriABottomColor : self.gradationColors?.attriBBottomColor
            let gradientColors: [CGColor] = [topColor!.cgColor, bottomColor!.cgColor]
            self.gradientLayer.colors = gradientColors
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    
    /*
     タスクを表示するViewを生成する
     */
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
        let currentY = mainScreenHeight / 2 - 50
        //titlesで定義したタブを1つずつ用意していく
        for (index, task) in tasks!.enumerated() {
            //タブになるUIVIewを作る
            taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
            taskView.frame = CGRect.init(x: originX + 25, y: currentY, width: 350.0, height: 300.0)
            taskView.setViewModel(task: task)
            taskView.setTableView()

            taskView.ticketTableView!.delegate = self
            taskView.ticketTableView!.dataSource = self
            
            taskView.tag = index + 1
            
            scrollView.addSubview(taskView)
            //次のタブのx座標を用意する
            originX += taskViewWidth
            
            if(index + 1 == 1) {
                self.centerViewAttri = taskView.taskViewModel!.attri
                //グラデーションの作成
                self.setGradationColor()
            }
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
    
    func getCenterTaskView() -> TaskView {
        let index = (self.taskViewIndex != nil) ? self.taskViewIndex! : 1
        let currentTaskView = self.view.viewWithTag(index) as! TaskView
        return currentTaskView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentTaskView = getCenterTaskView()
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
        if isShowDetail {
            return
        }
        //微妙なスクロール位置でスクロールをやめた場合に
        //ちょうどいいタブをセンターに持ってくるためのアニメーションです
        
        //現在のスクロールの位置(scrollView.contentOffset.x)から
        //どこのタブを表示させたいか計算します
        let taskCount = self.taskViewModel.tasks!.count
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * currentWidth
        //Viewが何番目かを計算
        let index = Int((scrollView.contentOffset.x + taskViewWidth/2) / taskViewWidth)
        let x = index * currentWidth
        //どれくらいスクロールしたのか
        let currentScroll = self.stopPoint - scrollView.contentOffset.x
        var scrollPoint = self.stopPoint
        if currentScroll < 0 {
            if currentScroll <= -75 {
                scrollPoint += CGFloat(currentWidth)
            }
        } else {
            if currentScroll >= 75 {
                scrollPoint -= CGFloat(currentWidth)
            }
        }
        //スクロール位置がスクロール可能最大値を超えないようにする
        if Int(scrollPoint) > maxScrollPoint {
            scrollPoint -= CGFloat(self.currentWidth)
        }
        //スクロール位置がマイナスになってしまう時は0を指定
        if Int(scrollPoint) < 0 {
            scrollPoint = 0
        }
        self.taskViewIndex = (Int(scrollPoint) / self.currentWidth) + 1
        let currentTaskView = self.getCenterTaskView()
        self.centerViewAttri = currentTaskView.taskViewModel!.attri
        print(self.centerViewAttri)
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
        })
        self.setGradationColor()
        self.stopPoint = scrollView.contentOffset.x
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        if isShowDetail {
            return
        }
        //慣性を消す
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)

    }

    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        if isShowDetail {
            return
        }
        //慣性を消す
       scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    /*
     縦方向へのスクロールを固定
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var p = scrollView.contentOffset
        p.y = self.isShowDetail ? scrollView.contentOffset.y : 0
        scrollView.contentOffset = p
    }

}

