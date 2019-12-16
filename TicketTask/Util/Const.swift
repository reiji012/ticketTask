//
//  Const.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/26.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

class Const {
    let TICKET_HEIGHT: CGFloat = 300
}

#if DEBUG // MARK: - 検証環境
    struct AdmobId {
        static let adsenceId = "ca-app-pub-3940256099942544/2934735716"
    }

#else // MARK: - 本番環境
    struct AdmobId {
        static let adsenceId = "ca-app-pub-7426200145056468~2355083259"
    }
#endif
