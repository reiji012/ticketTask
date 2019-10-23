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
        didSet {
            checkBoxLabel.textColor = isCompleted ? UIColor.white : UIColor.lightGray
            self.setButtonColor()
        }
    }
    
    @IBOutlet private weak var ticketNameLabel: UILabel!
    @IBOutlet private weak var checkBoxLabel: UILabel!

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
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.autoreverse], animations: {
            
            self.checkBoxLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
              self.checkBoxLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
        
        self.taskViewModel?.changeTicketCompleted(ticketName: ticketNameLabel.text!, completed: isCompleted)
        
        
    }
    
    func setButtonColor() {
        checkBoxLabel.backgroundColor = self.isCompleted ? self.taskViewModel?.taskColor?.gradationColor1 : UIColor.white
    }
}
