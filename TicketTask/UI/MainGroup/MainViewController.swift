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
import UICircularProgressRing
import GoogleMobileAds
import SwiftMessages

class VeryNiceSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
        dimMode = .blur(style: .dark, alpha: 0.4, interactive: true)
        messageView.configureNoDropShadow()
    }
}

protocol MainViewControllerProtocol {
    var stopPoint: CGFloat { get }
    var scrollWidth: Int { get }
    func setTaskEmptyViewState(isHidden: Bool)
    func createAllTaskViews()
    func didChangeTaskCount(taskCount: Int)
    func showValidateAlert(error: ValidateError)
    func deleteTask(view: TaskView)
    func configureAddTicketView()
    func configureProgressRing()
    func setCircleProgressValue(achievement: CGFloat, compCount: Int, unCompCount: Int)
}

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
    
    private var progressRing: UICircularProgressRing!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var weatherView: UIView!
    @IBOutlet private weak var taskAddButton: UIButton!
    @IBOutlet private weak var taskEmptyView: UIView!
    @IBOutlet weak var circleProgressSuperView: UIView!
    @IBOutlet weak var progressTitleTopHeightConst: NSLayoutConstraint!
    @IBOutlet weak var compCountLabel: UILabel!
    @IBOutlet weak var unCompCountLabel: UILabel!
    
    var bannerView: GADBannerView!
    
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
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = AdmobId.adsenceId
        bannerView.rootViewController = self
        let request = GADRequest()
        
        #if DEBUG // MARK: - 検証環境
            request.testDevices = ["d23b07b44930454621bf128502978077"]
        #endif
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
     bannerView.translatesAutoresizingMaskIntoConstraints = false
     view.addSubview(bannerView)
     view.addConstraints(
       [NSLayoutConstraint(item: bannerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0),
        NSLayoutConstraint(item: bannerView,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0)
       ])
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
        var contents = [TaskViewContentValue]()
        for i in 0..<presenter.taskTotalCount {
            let taskView = self.view.viewWithTag(i + 1) as! TaskView
            taskView.frame.size.height = self.taskViewHeight
            taskView.isCenter = false
            let content = TaskViewContentValue()
            content.tag = taskView.tag
            content.taskModel = presenter.getTaskModel(title: taskView.presenter.taskViewModel.taskName!)
            if content.taskModel != nil {
                contents.append(content)
            }
        }
        presenter.contents = contents
        
        if let currentTaskView: TaskView = self.getCenterTaskView() {
            let myBoundSize: CGSize = UIScreen.main.bounds.size
            currentTaskView.frame.size.height = self.isShowDetail ? myBoundSize.height : self.taskViewHeight
            currentTaskView.isCenter = true
            self.scrollView.bringSubviewToFront(currentTaskView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressRing.frame = circleProgressSuperView.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressRing.frame = circleProgressSuperView.frame
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segue = segue as? SwiftMessagesSegue {
            // 絞り込みPopup表示
            segue.configure(layout: .centered)
            segue.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
            segue.messageView.configureDropShadow()
            let viewController = segue.destination as? RefineViewController
            viewController!.delegate = self
            let button = sender as? UIButton
            if button!.tag == 0 {
                // 完了済
                let contents = presenter.contents.filter { presenter.completedTasks.contains($0.taskModel!) }
                viewController?.presenter = RefineViewPresenter(view: viewController!, contents: contents, uiContent: (title: "完了済みのタスク", color: TaskColor.orange.gradationColor1))
            } else {
                // 未完了
                let contents = presenter.contents.filter { presenter.uncompletedTasks.contains($0.taskModel!) }
                viewController?.presenter = RefineViewPresenter(view: viewController!, contents: contents, uiContent: (title: "未完了のタスク", color: .gray))            }
            return
        }
        
        let controller = segue.destination
        controller.transitioningDelegate = (self as UIViewControllerTransitioningDelegate)
        controller.modalPresentationStyle = .custom
        let nextVC = segue.destination as? AddTaskViewController
        nextVC?.mainVC = self
    }
    
    
    // MARK: - @IBAction Function
    @IBAction func touchAddButton(_ sender: Any) {
        let viewContreoller = AddTaskViewController.initiate()
        viewContreoller.mainVC = self
        let transitionDelegate = SPStorkTransitioningDelegate()
        viewContreoller.transitioningDelegate = transitionDelegate
        viewContreoller.modalPresentationStyle = .custom
        self.present(viewContreoller, animated: true, completion: nil)
    }
    
    @IBAction func touchCompletedButton(_ sender: UIButton) {
        performSegue(withIdentifier: "refineSegue", sender: sender)
    }
    
    @IBAction func touchUncompletedButton(_ sender: UIButton) {
        performSegue(withIdentifier: "refineSegue", sender: sender)
    }
    
    // MARK: - Public Function
    func configureProgressRing() {
        // create the view
        progressRing = UICircularProgressRing()
        progressRing.frame = circleProgressSuperView.frame
        progressRing.style = .ontop
        progressRing.value = 0
        progressRing.outerRingWidth = 7
        progressRing.outerRingColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        progressRing.fontColor = .white
        
        weatherView.addSubview(progressRing)
        
        if screenType == .iPhone4_0inch {
            progressTitleTopHeightConst.constant = 20
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
    
    
    func bindUI() {
        
        weatherView.isOpaque = false // 不透明を false
        weatherView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0) // alpha 0 で色を設定
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
            self.progressRing.innerRingColor = color.gradationColor1
            self.presenter.currentColor = color
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
        presenter.didChangedTaskProgress()
    }
    
    /// タスクビューを作成して表示させる
    /// - Parameter task: タスクデータ
    /// - Parameter tag: タスクViewタグ
    /// - Parameter isInitCreate: 初回表示時の作成フラグ
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
        taskView.delegate = self
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

    func showEditView(editTaskVC: EditTaskViewController, taskVM: TaskViewModel) {
        editTaskVC.mainVC = self
        UIView.animate(withDuration: 2, animations: {
            self.present(editTaskVC, animated: true, completion: nil)
        })
    }
    
    // タスクViewのサイズが変わる直前に呼ばれる
    func willChangedTaskViewSize() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                if self.isShowDetail {
                    // 拡大するとき
                    self.bannerView.alpha = 0
                    self.view.bringSubviewToFront(self.scrollView)
                    self.view.bringSubviewToFront(self.addTicketView!)
                } else {
                    // 縮小するとき
                    self.bannerView.isHidden = false
                    self.bannerView.alpha = 1
                    self.view.bringSubviewToFront(self.bannerView)
                }
            }, completion: { _ in
                if self.isShowDetail {
                    // 拡大するとき
                    self.bannerView.isHidden = true
                } else {
                    // 縮小するとき
                    self.bannerView.isHidden = false
                    self.view.bringSubviewToFront(self.weatherView)
                    self.view.bringSubviewToFront(self.taskAddButton)
                    self.view.bringSubviewToFront(self.bannerView)
                }
            })
        }
        
    }
    
    // タスクViewのサイズが変わったあとに呼ばれる
    func didChangedTaskViewSize() {
        
    }
    
    func setCircleProgressValue(achievement: CGFloat, compCount: Int, unCompCount: Int) {
        progressRing.value = achievement
        compCountLabel.text = "\(compCount)"
        unCompCountLabel.text = "\(unCompCount)"
    }
    
    
}

// MARK: - Extension MainViewControllerProtocol
extension MainViewController: MainViewControllerProtocol {
    /// タスクの削除
    /// - Parameter view: 削除するView
    func deleteTask(view: TaskView) {
        UIView.animate(withDuration: 0.2, animations: {
            // Viewを見えなくする
            view.alpha = 0
        }) { (completed) in
            // Animationが完了したら親Viewから削除する
            let index = view.tag
            let scrollPoint = self.stopPoint - CGFloat(self.scrollWidth)
            
            // 最後尾のViewかどうかで処理を分ける
            if (self.presenter.isLastTaskView(view: view)) {
                // 最後尾のViewの削除
                UIView.animate(withDuration: 0.5, animations: {
                    self.scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
                    self.stopPoint = scrollPoint
                }) { (completed) in
                    self.deletedTaskViews()
                }
            } else {
                // 最後尾以前のViewの削除
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
                }) { (completed) in
                    self.deletedTaskViews()
                }
                
            }
            // 次にViewを作成する時のためX座標の更新
            self.originX! -= CGFloat(self.scrollWidth)
            self.scrollView.isScrollEnabled = true
            self.taskAddButton.isHidden = false
            view.removeFromSuperview()
        }
    }
    
    func deletedTaskViews() {
        self.taskViewIndex = (Int(stopPoint) / self.scrollWidth) + 1
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

extension MainViewController: TaskViewDelegate {
    func didChangeTicketCompletion() {
        presenter.didChangedTaskProgress()
    }
}

extension MainViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}

extension MainViewController: RefineViewDelegate {
    func didSelected(tag: Int) {
        let scrollPoint = (tag - 1) * scrollWidth
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint(x:scrollPoint, y:0)
        })
        self.stopPoint = scrollView.contentOffset.x
        self.taskViewIndex = tag
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
    }
}
