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

enum TaskViewSize {
    case small
    case middle
    case large
    
    var viewWidth: CGFloat {
        switch self {
        case .small:
            return 256
        case .middle:
            return 311
        case .large:
            return 350
        }
    }
}

class MainViewController: UIViewController {
    
    var presenter: MainViewPresenterProtocol!
    
    // ViewModelの取得
    var taskViewModel = TaskViewModel()
    var centerViewAttri: String?
    var centerViewColor: String?
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
    var taskViewHeight: CGFloat!
    let taskViewWidth: CGFloat = 400.0
    let currentWidth: Int = 400
    var stopPoint: CGFloat = 0.0
    var originX:CGFloat?
    var ticketTaskColor: TicketTaskColor?
    func topSafeAreaHeight() -> CGFloat {
        return self.view.safeAreaInsets.top
    }
    
    let transition = BubbleTransition()
    
    var tabbarHeight: CGFloat!
    
    //カウンターアニメーションの時間設定
    private var counterAnimationLabelDuration: TimeInterval = 3.0
    
    private let initTaskViewHeight: CGFloat = 300
    private let initTaskViewWidth: CGFloat = 350
    private let initColor: String = TicketTaskColor().ORANGE
    
    private var dummyViewWidth: CGFloat!
    private var scrollViewHeight: CGFloat!
    
    private var taskViewSize: TaskViewSize?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var weatherImgView: UIImageView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var taskAddButton: UIButton!
    @IBOutlet weak var maxTempLabel: WeatherLabel!
    @IBOutlet weak var minTempLabel: WeatherLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var taskEmptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainViewPresenter(vc: self)
        presenter.viewDidLoad()
        // 端末のサイズでタスクカードの大きさを設定
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        switch myBoundSize.width {
        case 320:
            taskViewSize = .small
        case 375:
            taskViewSize = .middle
        case 414:
            taskViewSize = .large
        default:
            break
        }
        
        taskViewHeight = myBoundSize.height <= 600 ? 250 : 300
        dummyViewWidth = scrollView.frame.size.width/2 - taskViewWidth/2
        scrollViewHeight = scrollView.frame.size.height
        
        taskViewModel.getTaskData()
        scrollView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = false
        // Do any additional setup after loading the view.
        bindUI()
        taskViewModel.checkIsTaskEmpty()
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewDidLayoutSubviews() {
        self.tabbarHeight = self.tabBarController!.tabBar.frame.size.height
        for i in 0..<presenter.taskTotalCount {
            let taskView = self.view.viewWithTag(i + 1) as! TaskView
            let myBoundSize: CGSize = UIScreen.main.bounds.size
            taskView.frame.size.height = self.taskViewHeight
        }
        
        if let currentTaskView: TaskView = self.getCenterTaskView() {
            let myBoundSize: CGSize = UIScreen.main.bounds.size
            currentTaskView.frame.size.height = self.isShowDetail ? myBoundSize.height : self.taskViewHeight
        }
    }

    @IBAction func touchAddButton(_ sender: Any) {
        let viewContreoller = AddTaskViewController.initiate()
        viewContreoller.mainVC = self
        let transitionDelegate = SPStorkTransitioningDelegate()
        viewContreoller.transitioningDelegate = transitionDelegate
        viewContreoller.modalPresentationStyle = .custom
        self.present(viewContreoller, animated: true, completion: nil)
    }
    
    func bindUI() {
        
        weatherView.isOpaque = false // 不透明を false
        weatherView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0) // alpha 0 で色を設定
        weatherImgView.isOpaque = false // 不透明を false
        weatherImgView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0) // alpha 0 で色を設定
        ticketTaskColor = TicketTaskColor()
        // 影の設定
        self.taskAddButton.layer.shadowOpacity = 0.5
        self.taskAddButton.layer.shadowRadius = 12
        self.taskAddButton.layer.shadowColor = UIColor.black.cgColor
        self.taskAddButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        taskViewModel.delegate = self
        initGradationColor()
    }

    func changeTabbarStatus(isFront: Bool) {
//        self.tabBarController!.tabBar.isHidden = !isFront
        UIView.animate(withDuration: 2, animations: { () -> Void in
            if isFront {
                self.tabBarController!.tabBar.center.y -= 100
            } else {
                self.tabBarController!.tabBar.center.y += 100
            }
        })
    }

    func initGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let gradientColors: [CGColor] = self.ticketTaskColor!.getGradation(colorStr: self.initColor)
            self.gradientLayer.colors = gradientColors
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    func setGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            let gradientColors: [CGColor] = self.ticketTaskColor!.getGradation(colorStr: self.centerViewColor!)
            self.gradientLayer.colors = gradientColors
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    func addNewTaskView() {
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
        createTaskView(task: taskViewModel.taskModel!.lastCreateTask, tag: taskViewModel.taskModel!.tasks!.count, isInitCreate: false)
        
        print("self.originX!:\(self.originX!)")
        //scrollViewのcontentSizeを，View全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:self.originX! + taskViewWidth, height:scrollView.frame.height)
        
        HUD.flash(.success, onView: view, delay: 1)
        let taskCount: Int = self.presenter.taskTotalCount
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * currentWidth
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint(x:maxScrollPoint, y:0)
        })
        self.stopPoint = scrollView.contentOffset.x
        self.centerViewAttri = taskView.taskViewModel?.attri
        self.centerViewColor = taskView.taskViewModel?.colorString
        setGradationColor()
    }
    
    func createTaskView(task:Dictionary<String, Any>, tag: Int, isInitCreate: Bool){
        // VIewを設置する高さを計算する
        let mainScreenHeight: CGFloat = UIScreen.main.bounds.size.height
        let currentY = mainScreenHeight / 2 - 50
        
        let viewWidth = isInitCreate ? initTaskViewWidth : taskViewSize?.viewWidth
        
        taskView = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
        taskView.frame = CGRect.init(x: self.originX! + 25, y: currentY, width: viewWidth!, height: initTaskViewHeight)
        taskView.setViewModel(task: task, mainVC: self)
        taskView.setTableView()
        taskView.topSafeAreaHeight = self.view.safeAreaInsets.top
        taskView.tag = tag
        scrollView.addSubview(taskView)
        //次のタブのx座標を用意する
        self.originX! += taskViewWidth
    }
    
    func taskEdited(attri: String, color: String) {
        self.centerViewAttri = attri
        self.centerViewColor = color
        if let currentTaskView = getCenterTaskView() {
            currentTaskView.setGradationColor()
            setGradationColor()
        }
    }
    
    /// 画面中央のViewを取得
    ///
    /// - Returns: View
    func getCenterTaskView() -> TaskView? {
        let index = (self.taskViewIndex != nil) ? self.taskViewIndex! : 1
        guard let currentTaskView = self.view.viewWithTag(index) as? TaskView else {
            return nil
        }
        return currentTaskView
    }

    
    /// チケットの追加
    ///
    /// - Parameter ticket: 追加するチケット
    /// - Returns: エラー
    func didTouchAddTicketButton(ticket: String, view: TaskView) {
        view.taskViewModel?.actionType = .ticketCreate
        view.taskViewModel?.addTicket(ticketName: ticket)
        let ticketTableViewCell = UINib(nibName: "TicketTableViewCell", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TicketTableViewCell
        view.ticketTableView.reloadData()
    }
    
    /// タスクの削除
    ///
    /// - Parameter view: 削除するView
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
                        let currentTaskView = taskView as! TaskView
                        currentTaskView.tag = i - 1
                        let frame = currentTaskView.frame
                        currentTaskView.frame = CGRect(x: frame.origin.x - self.taskViewWidth, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
                        self.centerViewAttri = currentTaskView.taskViewModel?.attri
                        self.centerViewColor = currentTaskView.taskViewModel?.colorString
                        self.setGradationColor()
                    }
                })
                self.scrollView.isScrollEnabled = true
                self.taskAddButton.isHidden = false
                view.removeFromSuperview()
            }
            self.originX! -= self.taskViewWidth
        }
    }
    
    /// 最後尾のViewかどうか
    ///
    /// - Parameter view: 確認したいView
    /// - Returns: Bool
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        controller.transitioningDelegate = (self as UIViewControllerTransitioningDelegate)
        controller.modalPresentationStyle = .custom
        let nextVC = segue.destination as? AddTaskViewController
        nextVC?.mainVC = self
        nextVC?.beforeViewAttri = self.centerViewAttri!
    }
    
    func showEditView(editTaskVC: EditTaskViewController, taskVM: TaskViewModel) {
        editTaskVC.mainVC = self
        editTaskVC.taskViewModel = taskVM
        UIView.animate(withDuration: 2, animations: {
            self.present(editTaskVC, animated: true, completion: nil)
        })
    }
}

extension MainViewController: MainViewControllerProtocol {
    func didChangeTaskCount(taskCount: Int) {
        taskEmptyView.isHidden = taskCount < 1
    }
    
    
    /*
     タスクを表示するViewを生成する
     */
    func createTaskViews() {
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
        let tasks = presenter.tasks
        
        //タブの縦幅(UIScrollViewと一緒にします)
        let tabLabelHeight:CGFloat = self.scrollView.frame.size.height
        
        //右端にダミーViewを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let headDummyView = UIView()
        headDummyView.frame = CGRect(x:0, y:0, width:dummyViewWidth, height:tabLabelHeight)
        scrollView.addSubview(headDummyView)
        
        //タブのx座標．
        //ダミーView分，はじめからずらしてあげましょう．
        self.originX = dummyViewWidth
        
        //titlesで定義したタブを1つずつ用意していく
        for (index, task) in tasks.enumerated() {
            //タブになるUIVIewを作る
            createTaskView(task: task, tag: index + 1, isInitCreate: true)
            
            
            
            print(taskView.frame.size.width)
            if(index + 1 == 1) {
                self.centerViewAttri = taskView.taskViewModel!.attri
                self.centerViewColor = taskView.taskViewModel!.colorString
                //グラデーションの作成
                self.setGradationColor()
            }
        }
        
        //左端にダミーのUILabelを置く
        let tailLabel = UILabel()
        tailLabel.frame = CGRect(x:self.originX!, y:0, width:dummyViewWidth, height:tabLabelHeight)
        scrollView.addSubview(tailLabel)
        //ダミーLabel分を足して上げましょう
//        self.originX! += dummyViewWidth
        
        //scrollViewのcontentSizeを，View全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:self.originX! + taskViewWidth, height:scrollView.frame.height)
    }
    
    func setTaskEmptyViewState(isHidden: Bool) {
        taskEmptyView.isHidden = isHidden
        //タブの縦幅(UIScrollViewと一緒にします)
        let tabLabelHeight:CGFloat = UIScreen.main.bounds.size.height
        
        //右端にダミーViewを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let headDummyView = UIView()
        headDummyView.frame = CGRect(x:0, y:0, width:dummyViewWidth, height:tabLabelHeight)
        headDummyView.isUserInteractionEnabled = false
        scrollView.addSubview(headDummyView)
        
        //タブのx座標．
        //ダミーView分，はじめからずらしてあげましょう．
        self.originX = taskViewWidth
    }
    
    /// 天気情報のセット
    func setWeatherInfo() {
        DispatchQueue.main.async {
            self.descriptionLabel.text = "(\(self.presenter.getDescripiton()))"
            self.weatherImgView.image = self.presenter.weatherIconImage
            let maxTemp = self.presenter.getTodayWeatherMaxTemp()
            let minTemp = self.presenter.getTodayWeatherMinTemp()
            
            self.maxTempLabel.changeCountValueWithAnimation(Float(maxTemp)!, withDuration: self.counterAnimationLabelDuration, andAnimationType: .EaseOut, andCounterType: .Float)
            self.minTempLabel.changeCountValueWithAnimation(Float(minTemp)!, withDuration: self.counterAnimationLabelDuration, andAnimationType: .EaseOut, andCounterType: .Float)
            
        }
    }
    
    func showValidateAlert(error: ValidateError){
        
        var massage = ""
        var title = ""
        switch error {
        case .taskValidError:
            title = "データベースエラー"
            massage = error.rawValue
        case .ticketValidError:
            title = "入力エラー"
            massage = error.rawValue
        default:
            title = "保存に失敗しました"
        }
        
        let alert: UIAlertController = UIAlertController(title: title, message: massage, preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: UIScrollViewDelegate {

    /*
     縦方向へのスクロールを固定
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var p = scrollView.contentOffset
        p.y = self.isShowDetail ? scrollView.contentOffset.y : 0
        scrollView.contentOffset = p
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.scrollView else { return }
        if isShowDetail  {
            return
        }
        //微妙なスクロール位置でスクロールをやめた場合に
        //ちょうどいいタブをセンターに持ってくるためのアニメーション
        
        //現在のスクロールの位置(scrollView.contentOffset.x)から
        //どこのタブを表示させたいか計算
        let taskCount: Int = presenter.taskTotalCount
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
        if let currentTaskView = self.getCenterTaskView() {
            self.centerViewAttri = currentTaskView.taskViewModel!.attri
            self.centerViewColor = currentTaskView.taskViewModel!.colorString
        }
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
} 

extension MainViewController : UIViewControllerTransitioningDelegate{
    
}
