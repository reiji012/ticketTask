//
//  DBError.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/31.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation

enum ValidateError: String {
    case taskValidError = "同じ名前のタスクが存在します"
    case ticketValidError = "チケットが重複しています"
    case taskDeleteValidError = "これ以上タスクを削除できません"
    case ticketDeleteValidError = "これ以上チケットを削除できません"
    case inputValidError = "入力エラーです"
    case titleEmptyError = "タイトルを入力してください"

    var massage: String {
        switch self {
        case .inputValidError:
            return ""
        default:
            return ""
        }
    }

}
