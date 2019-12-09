//
//  NotificationTableCell.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/14.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

protocol NotificationTableCellDelegate {
    func didTouchSwitchButton(isActive: Bool, identifier: String?)
}

class NotificationTableCell: UITableViewCell {
    
    var delegate: NotificationTableCellDelegate?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    var identifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func touchSwitchButton(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        
        delegate.didTouchSwitchButton(isActive: switchButton.isOn, identifier: identifier)
    }
}
