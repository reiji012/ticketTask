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

class MainViewController: UIViewController {
    
    // MARK: - Public Propaty
    // ViewModelの取得
    var taskViewModel = TaskViewModel()
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
    let taskViewWidth: CGFloat = screenType.taskViewCardWidth
    var scrollWidth: Int = Int(screenType.taskViewCardWidth + 15)
    var stopPoint: CGFloat = 0.0
    var originX:CGFloat?
    func topSafeAreaHeight() -> CGFloat {
        return self.view.safeAreaInsets.top
    }
    let transition = BubbleTransition()
    var tabbarHeight: CGFloat!
    var addTicketView: AddTicketView?
    
    // MARK: - Private Property
    private var presenter: MainViewPresenterProtocol!
    //カウンターアニメーションの時間設定
    private var counterAnimationLabelDuration: TimeInterval = 3.0
    
    private let initTaskViewHeight: CGFloat = 300
    private let initTaskViewWidth: CGFloat = 350
    private var dummyViewWidth: CGFloat!
    private var scrollViewHeight: CGFloat!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var weatherImgView: UIImageView!
    @IBOutlet private weak var weatherView: UIView!
    @IBOutlet private weak var taskAddButton: UIButton!
    @IBOutlet private weak var maxTempLabel: WeatherLabel!
    @IBOutlet private weak var minTempLabel: WeatherLabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var taskEmptyView: UIView!
    
    // MARK: - Initilizer
    static func initiate() -> MainViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = MainViewPresenter(vc: viewController)
        return viewController
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainViewPresenter(vc: self)
        presenter.viewDidLoad()
        // 端末のサイズでタスクカードの大きさを設定
        let myBoundSize: CGSize = UIScreen.main.bounds.size
    
        taskViewHeight = myBoundSize.height <= 600 ? 250 : 300
        dummyViewWidth = scrollView.frame.size.width/2 - taskViewWidth/2
        scrollViewHeight = scrollView.frame.size.height
        
        scrollView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = false
        // Do any additional setup after loading the view.
        bindUI()
        presenter.checkIsTaskEmpty()
    }
    
    override func viewWillLayoutSubviews() {
        if let currentTaskView = taskView {
            currentTaskView.setGradationColor(color: currentTaskView.presenter.currentColor)
            DispatchQueue.main.async {
                self.setGradationColor(color: currentTaskView.presenter.taskViewModel.taskColor!)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.tabbarHeight = 0
        for i in 0..<presenter.taskTotalCount {
            let taskView = self.view.viewWithTag(i + 1) as! TaskView
            taskView.frame.size.height = self.taskViewHeight
            taskView.isCenter = false
        }
        
        if let currentTaskView: TaskView = self.getCenterTaskView() {
            let myBoundSize: CGSize = UIScreen.main.bounds.size
            currentTaskView.frame.size.height = self.isShowDetail ? myBoundSize.height : self.taskViewHeight
            currentTaskView.isCenter = true
            self.scrollView.bringSubviewToFront(currentTaskView)
        }
    }
    
    func configureAddTicketView() {
        addTicketView = AddTicketView.initiate(taskModel: TaskModel(id: 0))
        addTicketView!.delegate = self
        addTicketView!.frame = self.view.frame
        addTicketView!.defaultCenterY = self.view.center.y
        self.view.addSubview(addTicketView!)
        addTicketView!.isHidden = true
    }
    
    // MARK: - Public Function
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
        // 影の設定
        self.taskAddButton.layer.shadowOpacity = 0.5
        self.taskAddButton.layer.shadowRadius = 12
        self.taskAddButton.layer.shadowColor = UIColor.black.cgColor
        self.taskAddButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        taskViewModel.delegate = self
        initGradationColor()
    }

    func initGradationColor() {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            // 何もタスクがないときはオレンジのグラデーションにする
            self.gradientLayer.colors = TaskColor.orange.gradationColor
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    func setGradationColor(color: TaskColor) {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.gradientLayer.colors = color.gradationColor
            self.gradientLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        })
    }
    
    func addNewTaskView() {
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
        createTaskView(task: taskViewModel.taskLocalDataModel!.lastCreateTask!, tag: taskViewModel.taskLocalDataModel!.tasks.count, isInitCreate: false)
        
        print("self.originX!:\(self.originX!)")
        //scrollViewのcontentSizeを，View全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:self.originX! + taskViewWidth, height:scrollView.frame.height)
        
        HUD.flash(.success, onView: view, delay: 1)
        let taskCount: Int = self.presenter.taskTotalCount
        //スクロール可能最大値
        let maxScrollPoint = (taskCount - 1) * scrollWidth
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint(x:maxScrollPoint, y:0)
        })
        self.stopPoint = scrollView.contentOffset.x
        self.taskViewIndex = (Int(self.stopPoint) / self.scrollWidth) + 1
    }
    
    func createTaskView(task:TaskModel, tag: Int, isInitCreate: Bool){
        taskEmptyView.isHidden = true
        // VIewを設置する高さを計算する
        let mainScreenHeight: CGFloat = UIScreen.main.bounds.size.height
        let currentY = mainScreenHeight / 2 - 50
        
        let viewWidth = isInitCreate ? initTaskViewWidth : screenType.taskViewCardWidth
        
        taskView = TaskView.initiate(mainViewController: self, task: task)
        taskView.frame = CGRect.init(x: self.originX!, y: currentY, width: viewWidth, height: initTaskViewHeight)
        taskView.bind()
        taskView.setLayout()
        taskView.topSafeAreaHeight = self.view.safeAreaInsets.top
        taskView.tag = tag
        scrollView.addSubview(taskView)
        //次のタブのx座標を用意する
        self.originX! += CGFloat(scrollWidth)
        scrollView.bringSubviewToFront(taskView)
    }
    
    func taskEdited(currentTaskView: TaskView) {
        taskView = currentTaskView
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        controller.transitioningDelegate = (self as UIViewControllerTransitioningDelegate)
        controller.modalPresentationStyle = .custom
        let nextVC = segue.destination as? AddTaskViewController
        nextVC?.mainVC = self
    }
    
    func showEditView(editTaskVC: EditTaskViewController, taskVM: TaskViewModel) {
        editTaskVC.mainVC = self
        UIView.animate(withDuration: 2, animations: {
            self.present(editTaskVC, animated: true, completion: nil)
        })
    }
}

// MARK: - Extension MainViewControllerProtocol
extension MainViewController: MainViewControllerProtocol {
    /// タスクの削除
    ///
    /// - Parameter view: 削除するView
    func deleteTask(view: TaskView) {
        UIView.animate(withDuration: 0.2, animations: {
            // Viewを見えなくする
            view.alpha = 0
        }) { (completed) in
            // Animationが完了したら親Viewから削除する
            let index = view.tag
            let scrollPoint = self.stopPoint - CGFloat(self.scrollWidth)
            if (self.presenter.isLastTaskView(view: view)) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
                    self.stopPoint = scrollPoint
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    for i in index..<self.scrollView.subviews.count {
                        guard let taskView = self.view.viewWithTag(i) as? TaskView else {
                            return
                        }
                        taskView.tag = i - 1
                        let frame = taskView.frame
                        taskView.frame = CGRect(x: frame.origin.x - CGFloat(self.scrollWidth), y: frame.origin.y, width: frame.size.width, height: frame.size.height)
                        self.setGradationColor(color: taskView.presenter.taskViewModel.taskColor!)
                    }
                })
                self.scrollView.isScrollEnabled = true
                self.taskAddButton.isHidden = false
                view.removeFromSuperview()
            }
            self.originX! -= self.taskViewWidth
        }
    }
    
    func didChangeTaskCount(taskCount: Int) {
        taskEmptyView.isHidden = taskCount != 0
    }
    
    
    /*
     タスクを表示するViewを生成する
     */
    func createAllTaskViews() {
        //scrollViewのDelegateを指定
        scrollView.delegate = self
        
        let tasks = presenter.tasks
        var firstTaskView = TaskView()
        //titlesで定義したタブを1つずつ用意していく
        for (index, task) in tasks.enumerated() {
            //タブになるUIVIewを作る
            createTaskView(task: task, tag: index + 1, isInitCreate: true)
            
            print(taskView.frame.size.width)
            if(index + 1 == 1) {
                //グラデーションの作成
                self.setGradationColor(color: taskView.presenter.taskViewModel.taskColor!)
                // グラデーションカラーを先頭のViewのカラーにしたいので変数に保持しておく
                firstTaskView = self.taskView
            }
        }
        self.taskView = firstTaskView
        //左端にダミーのUILabelを置く
        let tailLabel = UILabel()
        tailLabel.frame = CGRect(x:self.originX!, y:0, width:dummyViewWidth, height:self.scrollView.frame.size.height)
        scrollView.addSubview(tailLabel)
        
        //scrollViewのcontentSizeを，View全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅 になります
        scrollView.contentSize = CGSize(width:self.originX! + taskViewWidth, height:scrollView.frame.height)
    }
    
    func setTaskEmptyViewState(isHidden: Bool) {
        taskEmptyView.isHidden = isHidden
        //右端にダミーViewを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let headDummyView = UIView()
        headDummyView.frame = CGRect(x:0, y:0, width:dummyViewWidth, height:self.scrollView.frame.size.height)
        scrollView.addSubview(headDummyView)
        
        //タブのx座標．
        //ダミーView分，はじめからずらしてあげましょう．
        self.originX = 32
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
        presenter.catchError(error: error)
    }
}

// MARK: - Extension UIScrollViewDelegate
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
        let maxScrollPoint = (taskCount - 1) * scrollWidth
        //どれくらいスクロールしたのか
        let currentScroll = self.stopPoint - scrollView.contentOffset.x
        var scrollPoint = self.stopPoint
        if currentScroll < 0 {
            if currentScroll <= -75 {
                scrollPoint += CGFloat(scrollWidth)
            }
        } else {
            if currentScroll >= 75 {
                scrollPoint -= CGFloat(scrollWidth)
            }
        }
        //スクロール位置がスクロール可能最大値を超えないようにする
        if Int(scrollPoint) > maxScrollPoint {
            scrollPoint -= CGFloat(self.scrollWidth)
        }
        //スクロール位置がマイナスになってしまう時は0を指定
        if Int(scrollPoint) < 0 {
            scrollPoint = 0
        }
        self.taskViewIndex = (Int(scrollPoint) / self.scrollWidth) + 1
        for i in 0..<presenter.taskTotalCount {
            let taskView = self.view.viewWithTag(i + 1) as! TaskView
            taskView.isCenter = false
        }
        if let currentTaskView = self.getCenterTaskView() {
            self.setGradationColor(color: currentTaskView.presenter.taskViewModel.taskColor!)
            currentTaskView.isCenter = true
            self.taskView = currentTaskView
            self.scrollView.bringSubviewToFront(currentTaskView)
        }
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
        })
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

extension MainViewController {
    func didTouchAddTicketButton(title: String, memo: String, identifier: String? = nil) {
        if let identifier = identifier {
            addTicketView!.showView(title: title, memo: memo, identifier: identifier)
        } else {
            addTicketView!.showView(title: title, memo: memo)
        }
    }
}

extension MainViewController: AddTicketViewDelegate {
    func didTouchCheckButtonAsEdit(title: String, memo: String, identifier: String) {
        
    }
    
    func didTouchCheckButton(title: String, memo: String) {
        
    }
    
    func didTouchCloseButton() {
    }
}
