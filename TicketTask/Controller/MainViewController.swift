//
//  ViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/07.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BubbleTransition
import SPStorkController
import SparrowKit
import PKHUD

class MainViewController: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,MainDelegate {
    
    // ViewModelの取得
    var taskViewModel = TaskViewModel()
    var centerViewAttri: String?
    var tableViewArray = [UITableViewCell]()
    var taskViewIndex: Int?
    var isShowDetail: Bool = false {
        didSet(value) {
            self.scrollView.isScrollEnabled = value
            self.taskAddButton.isHidden = !value
        }
    }
    weak var taskView: TaskView!
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    //TaskViewの横幅
    let taskViewWidth:CGFloat = 400.0
    let currentWidth: Int = 400
    var stopPoint: CGFloat = 0.0
    var originX:CGFloat?
    var gradationColors: GradationColors?
    func topSafeAreaHeight() -> CGFloat {
        return self.view.safeAreaInsets.top
    }
    
    let transition = BubbleTransition()
    
    //カウンターアニメーションの時間設定
    private var counterAnimationLabelDuration: TimeInterval = 3.0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var weatherImgView: UIImageView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var taskAddButton: UIButton!
    @IBOutlet weak var maxTempLabel: WeatherLabel!
    @IBOutlet weak var minTempLabel: WeatherLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskViewModel.getTaskData()
        taskViewModel.setupWetherInfo()
        scrollView.delegate = self
        taskViewModel.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        // Do any additional setup after loading the view.
        bindUI()
        createTaskViews()
    }

    @IBAction func pushAddBtn(_ sender: Any) {
        let storyboard = self.storyboard
        let addTaskVC = storyboard!.instantiateViewController(withIdentifier: "addView") as! AddTaskViewController
        let transitionDelegate = SPStorkTransitioningDelegate()
        addTaskVC.mainVC = self
        addTaskVC.transitioningDelegate = transitionDelegate
        addTaskVC.modalPresentationStyle = .custom
        self.present(addTaskVC, animated: true, completion: nil)
    }
    func bindUI() {
        
        weatherView.isOpaque = false // 不透明を false
        weatherView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0) // alpha 0 で色を設定
        weatherImgView.isOpaque = false // 不透明を false
        weatherImgView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0) // alpha 0 で色を設定
        gradationColors = GradationColors()
        // 影の設定
        self.taskAddButton.layer.shadowOpacity = 0.5
        self.taskAddButton.layer.shadowRadius = 12
        self.taskAddButton.layer.shadowColor = UIColor.black.cgColor
        self.taskAddButton.layer.shadowOffset = CGSize(width: 3, height: 4)
    }


    func setGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let topColor = self.centerViewAttri! == "生活" ? self.gradationColors?.attriLifeTopColor : self.gradationColors?.attriWorkTopColor
            let bottomColor = self.centerViewAttri! == "生活" ? self.gradationColors?.attriLifeBottomColor : self.gradationColors?.attriWorkBottomColor
            let gradientColors: [CGColor] = [topColor!.cgColor, bottomColor!.cgColor]
            self.gradientLayer.colors = gradientColors
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for i in 0..<self.taskViewModel.taskCount() {
            let taskView = self.view.viewWithTag(i + 1) as! TaskView
            taskView.frame.size.height = 300
        }
    }
    
    /*
     タスクを表示するViewを生成する
     */
    func createTaskViews() {
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
        let tasks = taskViewModel.tasks
        
        //タブの縦幅(UIScrollViewと一緒にします)
        let tabLabelHeight:CGFloat = UIScreen.main.bounds.size.height
        
        //右端にダミーのUILabelを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let dummyLabelWidth = scrollView.frame.size.width/2 - taskViewWidth/2
        let headDummyLabel = UIView()
        headDummyLabel.frame = CGRect(x:0, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        scrollView.addSubview(headDummyLabel)
        
        //タブのx座標．
        //ダミーLabel分，はじめからずらしてあげましょう．
        self.originX = dummyLabelWidth
        
        // VIewを設置する高さを計算する
        let mainScreenHeight: CGFloat = UIScreen.main.bounds.size.height
        let currentY = mainScreenHeight / 2 - 50
        //titlesで定義したタブを1つずつ用意していく
        for (index, task) in tasks!.enumerated() {
            //タブになるUIVIewを作る
            taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
            taskView.frame = CGRect.init(x: self.originX! + 25, y: currentY, width: 350.0, height: 300.0)
            taskView.setViewModel(task: task)
            taskView.setTableView()
            taskView.topSafeAreaHeight = self.view.safeAreaInsets.top
            taskView.ticketTableView!.delegate = self
            taskView.ticketTableView!.dataSource = self
            
            taskView.tag = index + 1
            
            scrollView.addSubview(taskView)
            //次のタブのx座標を用意する
            self.originX! += taskViewWidth
            
            print(taskView.frame.size.width)
            if(index + 1 == 1) {
                self.centerViewAttri = taskView.taskViewModel!.attri
                //グラデーションの作成
                self.setGradationColor()
            }
        }
        
        //左端にダミーのUILabelを置く
        let tailLabel = UILabel()
        tailLabel.frame = CGRect(x:self.originX!, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        scrollView.addSubview(tailLabel)
        
        //ダミーLabel分を足して上げましょう
        self.originX! += dummyLabelWidth
        
        //scrollViewのcontentSizeを，View全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:self.originX!, height:scrollView.frame.height)
    }
    
    func addNewTaskView() {
        let currentTaskView = self.getCenterTaskView()
        let mainScreenHeight: CGFloat = UIScreen.main.bounds.size.height
        let currentY = mainScreenHeight / 2 - 50
        taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
        taskView.frame = CGRect.init(x: self.originX! + 18, y: currentY, width: currentTaskView.frame.size.width, height: currentTaskView.frame.size.height)
        taskView.setViewModel(task: taskViewModel.taskModel!.lastCreateTask)
        taskView.setTableView()
        
        taskView.ticketTableView!.delegate = self
        taskView.ticketTableView!.dataSource = self
        
        taskView.tag = taskViewModel.taskModel!.tasks!.count
        
        scrollView.addSubview(taskView)
        self.originX! += taskViewWidth
        
        //scrollViewのcontentSizeを，View全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:self.originX!, height:scrollView.frame.height)

        
        HUD.flash(.success, onView: view, delay: 1)
        let taskCount: Int = self.taskViewModel.taskCount()
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * currentWidth
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint(x:maxScrollPoint, y:0)
        })
        self.stopPoint = scrollView.contentOffset.x
        self.centerViewAttri = taskView.taskViewModel?.attri
        setGradationColor()
    }
    
    func taskEdited(attri: String) {
        self.centerViewAttri = attri
        let currentTaskView = getCenterTaskView()
        currentTaskView.setGradationColor()
        setGradationColor()
    }
    
    func getCenterTaskView() -> TaskView {
        let index = (self.taskViewIndex != nil) ? self.taskViewIndex! : 1
        let currentTaskView = self.view.viewWithTag(index) as! TaskView
        return currentTaskView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentTaskView = getCenterTaskView()
        return currentTaskView.ticketsCount
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
        if tableViewCell is TicketTableViewCell {
            let currentTableViewCell: TicketTableViewCell = tableViewCell as! TicketTableViewCell
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
            currentTableViewCell.ticketNameLabel.text = ticketName
            return currentTableViewCell
        }
        
        return UITableViewCell()
    }
    
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let currentTaskView: TaskView
        if self.taskViewIndex == nil {
            currentTaskView = self.view.viewWithTag(1) as! TaskView
        } else {
            currentTaskView = self.view.viewWithTag(taskViewIndex!) as! TaskView
        }
        if editingStyle == .delete {
            let tableViewCell = currentTaskView.tableViewArray[indexPath.row] as! TicketTableViewCell
            let ticketName = tableViewCell.ticketNameLabel.text
            currentTaskView.taskViewModel?.actionType = .ticketDelete
            currentTaskView.taskViewModel?.tickets?.removeValue(forKey: ticketName!)
            currentTaskView.tableViewArray.remove(at: indexPath.row)
            currentTaskView.ticketTableView.reloadData()
        }
    }
    
    func addTicket(ticket: String) -> ValidateError? {
        let currentTaskView: TaskView
        if self.taskViewIndex == nil {
            currentTaskView = self.view.viewWithTag(1) as! TaskView
        } else {
            currentTaskView = self.view.viewWithTag(taskViewIndex!) as! TaskView
        }
        currentTaskView.taskViewModel?.actionType = .ticketCreate
        let error = currentTaskView.taskViewModel?.addTicket(ticketName: ticket)
        if error != nil {
            return error
        }
        let ticketTableViewCell = UINib(nibName: "TicketTableViewCell", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TicketTableViewCell
        currentTaskView.tableViewArray.append(ticketTableViewCell!)
        currentTaskView.ticketTableView.reloadData()
        return nil
    }
    
    func deleteTask(view: TaskView) {
        view.taskViewModel?.updateModel(actionType: .taskDelete)
        UIView.animate(withDuration: 0.2, animations: {
            // Viewを見えなくする
            view.alpha = 0
        }) { (completed) in
            // Animationが完了したら親Viewから削除する
            let index = view.tag
            let scrollPoint = self.stopPoint - CGFloat(self.currentWidth)
            if (self.isLaskTaskView(view: view)) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
                    self.stopPoint = scrollPoint
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    for i in index..<100 {
                        guard let taskView = self.view.viewWithTag(i) else {
                            return
                        }
                        taskView.tag = i - 1
                        let frame = taskView.frame
                        taskView.frame = CGRect(x: frame.origin.x - self.taskViewWidth, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
                    }
                })
                self.scrollView.isScrollEnabled = true
                self.taskAddButton.isHidden = false
                view.removeFromSuperview()
            }
        }
    }
    
    func isLaskTaskView(view: TaskView) -> Bool {
        //どこのタブを表示させたいか計算します
        let taskCount: Int = self.taskViewModel.taskCount()
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * currentWidth
        if (maxScrollPoint < Int(self.stopPoint)) {
            return true
        } else {
            return false
        }
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
        let taskCount: Int = self.taskViewModel.taskCount()
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * currentWidth
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
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
        })
        print(taskView.frame.size.width)
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        controller.transitioningDelegate = (self as UIViewControllerTransitioningDelegate)
        controller.modalPresentationStyle = .custom
        let nextVC = segue.destination as? AddTaskViewController
        nextVC?.mainVC = self
        nextVC?.taskViewModel = self.taskViewModel
        nextVC?.beforeViewAttri = self.centerViewAttri!
    }
    
    func showEditView(editTaskVC: EditTaskViewController, taskVM: TaskViewModel) {
        editTaskVC.mainVC = self
        editTaskVC.taskViewModel = taskVM
        UIView.animate(withDuration: 2, animations: {
            self.present(editTaskVC, animated: true, completion: nil)
        })
        
    }
    
    func showAddTicketView(addTicketVC: AddTicketViewController, taskVM: TaskViewModel) {
        addTicketVC.mainVC = self
        addTicketVC.taskViewModel = taskVM
        UIView.animate(withDuration: 2, animations: {
            self.present(addTicketVC, animated: true, completion: nil)
        })
    }
    
    func setWeatherInfo() {
        DispatchQueue.main.async {
            self.descriptionLabel.text = "(\(self.taskViewModel.todayWetherInfo![WetherInfoConst.DESCRIPTION.rawValue]!))"
            self.weatherImgView.image = self.taskViewModel.weatherIconImage
            
            self.maxTempLabel.changeCountValueWithAnimation(Float("\(self.taskViewModel.todayWetherInfo![WetherInfoConst.TEMP_MAX.rawValue]!)")!, withDuration: self.counterAnimationLabelDuration, andAnimationType: .EaseOut, andCounterType: .Float)
            self.minTempLabel.changeCountValueWithAnimation(Float("\(self.taskViewModel.todayWetherInfo![WetherInfoConst.TEMP_MIN.rawValue]!)")!, withDuration: self.counterAnimationLabelDuration, andAnimationType: .EaseOut, andCounterType: .Float)
            
        }
    }
    
}

extension MainViewController : UIViewControllerTransitioningDelegate{
    
    //　手順⑤
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .present
//        transition.startingPoint = taskAddButton.center    //outletしたボタンの名前を使用
//        transition.bubbleColor = self.gradationColors!.addViewBottomColor
//        return transition
//    }
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .dismiss
//        transition.startingPoint = taskAddButton.center //outletしたボタンの名前を使用
//        transition.bubbleColor = self.gradationColors!.addViewBottomColor
//        return transition
//    }
}
