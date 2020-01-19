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
            self.setButtonColor()
        }
    }
    var checkedImage: UIImage = UIImage(named: "checked_Mark")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    var unCheckedImage: UIImage = UIImage(named: "unChecked_Mark")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    
    @IBOutlet weak var ticketNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func touchCheckButton(_ sender: UIButton) {
        self.isCompleted = !self.isCompleted
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.autoreverse], animations: {
            
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
              sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
        
        self.taskViewModel?.changeTicketCompleted(ticketName: ticketNameLabel.text!, completed: isCompleted)
        
    }
    
    func setButtonColor() {
        let image = self.isCompleted ? checkedImage : unCheckedImage
        checkButton.setImage(image, for: .normal)
        checkButton.tintColor = self.isCompleted ? self.taskViewModel?.taskColor?.gradationColor1 : .gray
    }
}
