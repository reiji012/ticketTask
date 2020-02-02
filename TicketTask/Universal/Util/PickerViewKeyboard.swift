//
//  PickerViewKeyboard.swift
//  TicketTask
//
//  Created by 999-308 on 2019/11/14.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import UIKit

protocol PickerViewKeyboardDelegate {
    func initSelectedRow(sender: PickerViewKeyboard) -> Int
    func didCancel(sender: PickerViewKeyboard)
    func didDone(sender: PickerViewKeyboard, selectedData: Date)
}

class PickerViewKeyboard: UIButton {
    var delegate: PickerViewKeyboardDelegate!
    var pickerView: UIDatePicker!
    var toolbar: UIToolbar!

    override var canBecomeFirstResponder: Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }

    @objc func didTouchUpInside(_ sender: UIButton) {
        becomeFirstResponder()
    }

    override var inputView: UIView? {
        pickerView = UIDatePicker()
        //        pickerView.setDate(Date(),animated: true)
        pickerView.datePickerMode = UIDatePicker.Mode.time
        pickerView.locale = Locale(identifier: "ja_JP")
        pickerView.addTarget(self, action: #selector(fixNotificationTime(sender:)), for: .valueChanged)

        return pickerView
    }

    override var inputAccessoryView: UIView? {
        toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 12
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PickerViewKeyboard.cancelPicker))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickerViewKeyboard.donePicker))

        let toolbarItems = [space, cancelItem, flexSpaceItem, doneButtonItem, space]

        toolbar.setItems(toolbarItems, animated: true)

        return toolbar
    }

    @objc func cancelPicker() {
        delegate.didCancel(sender: self)

    }

    @objc func donePicker() {
        delegate.didDone(sender: self, selectedData: self.pickerView!.date)
    }

    // 通知時間の確定
    @objc func fixNotificationTime(sender: UIDatePicker) {
        pickerView.date = sender.date
    }
}
