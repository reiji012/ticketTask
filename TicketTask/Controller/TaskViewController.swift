//
//  TaskViewController.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/25.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    
    var taskViewModel: TaskViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = UINib(nibName: "TaskView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? TaskView
    }

    func setTableView() {
        let view = self.view as! TaskView
        view.ticketTableView.estimatedRowHeight = 150
        for _ in taskViewModel!.tickets! {
            self.ticketTableView.register(UINib(nibName: "TicketTableViewCell", bundle: nil), forCellReuseIdentifier: "TicketTableViewCell")
            
            guard let ticketTableViewCell = self.ticketTableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell") as? TicketTableViewCell else {
                return
            }
            self.tableViewArray.append(ticketTableViewCell)
        }
    }

}
