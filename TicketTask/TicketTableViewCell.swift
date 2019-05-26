//
//  TicketTableViewCell.swift
//  TicketTask
//
//  Created by 松村礼二 on 2019/05/08.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class TicketTableViewCell: UITableViewCell {
    
    var parentTaskView: TaskView?
    var taskViewModel: TaskViewModel?
    var isCompleted: Bool = false {
        didSet(value) {
            
            checkBoxLabel.textColor = isCompleted ? UIColor.green : UIColor.lightGray
        }
    }
    
    @IBOutlet weak var ticketName: UILabel!
    @IBOutlet weak var checkBoxLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkBoxLabel.text = "✔︎"
        //ViewModelの取得
        parentTaskView = (self.parent?.parent as! TaskView)
        self.taskViewModel = parentTaskView?.taskViewModel!
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.changeCompletion))
        checkBoxLabel.isUserInteractionEnabled = true
        checkBoxLabel.addGestureRecognizer(gesture)
        // Configure the view for the selected state
    }
    
    @objc func changeCompletion() {
        self.isCompleted = !self.isCompleted
        self.taskViewModel?.changeTicketCompleted(ticketName: ticketName.text!, completed: isCompleted)
    }
}
