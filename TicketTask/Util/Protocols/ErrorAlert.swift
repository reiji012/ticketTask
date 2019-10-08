//
//  ErrorAlert.swift
//  TicketTask
//
//  Created by 999-308 on 2019/10/08.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorAlert{
    func createErrorAlert(error: ValidateError, massage: String?, view: UIViewController)
    func showValidateAlert(title: String, massage: String, view: UIViewController)
}

extension ErrorAlert {
    func createErrorAlert(error: ValidateError, massage: String?, view: UIViewController) {
        var _massage = ""
        var title = ""
        
        switch error {
        case .inputValidError:
            title = "入力エラー"
            if let massage = massage {
                _massage = massage
            }
        case .taskValidError:
            title = "データベースエラー"
            _massage = error.rawValue
        case .ticketValidError:
            title = "入力エラー"
            _massage = error.rawValue
        default:
            title = "保存に失敗しました"
        }
        
        showValidateAlert(title: title, massage: _massage, view: view)
    }
    func showValidateAlert(title: String, massage: String, view: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: title, message: massage, preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        alert.addAction(defaultAction)
        
        view.present(alert, animated: true, completion: nil)
    }
}
