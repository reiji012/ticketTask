////
////  TaskScrollView.swift
////  TicketTask
////
////  Created by 松村礼二 on 2019/05/09.
////  Copyright © 2019 松村礼二. All rights reserved.
////
//
//import UIKit
//import Foundation
//
//class TaskScrollView: UIScrollView {
//
//    // タップ開始時のスクロール位置格納用
//    var dstartPoint : CGPoint?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame);
//        Initialize();
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder);
//        Initialize();
//    }
//    
//    // initialize method
//    func Initialize(){
//        self.delegate = self;
//        
//        // 横固定なので縦のIndicatorいらない
//        self.showsVerticalScrollIndicator = false;
//    }
//}
//
//extension TaskScrollView : UIScrollViewDelegate{
//    
//    // ドラッグ開始時のスクロール位置記憶
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        self.dstartPoint = scrollView.contentOffset;
//    }
//    
//    // ドラッグ(スクロール)しても y 座標は開始時から動かないようにする(固定)
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        scrollView.contentOffset.y = self.dstartPoint!.y;
//    }
//}
