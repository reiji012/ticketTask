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
            checkBoxLabel.textColor = isCompleted ? UIColor.white : UIColor.lightGray
            checkBoxLabel.backgroundColor = self.isCompleted ? self.taskViewModel?.taskColor?.gradationColor1 : UIColor.white
        }
    }
    
    @IBOutlet weak var ticketNameLabel: UILabel!
    @IBOutlet weak var checkBoxLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        checkBoxLabel.text = "✔︎"
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.changeCompletion))
        checkBoxLabel.isUserInteractionEnabled = true
        checkBoxLabel.addGestureRecognizer(gesture)
        // Configure the view for the selected state
    }
    
    @objc func changeCompletion() {
        self.isCompleted = !self.isCompleted
        self.taskViewModel?.changeTicketCompleted(ticketName: ticketNameLabel.text!, completed: isCompleted)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn, .autoreverse], animations: {
            
            self.checkBoxLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            self.checkBoxLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
