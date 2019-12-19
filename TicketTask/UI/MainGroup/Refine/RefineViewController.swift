//
//  RefineViewController.swift
//  TicketTask
//
//  Created by 999-308 on 2019/12/19.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

protocol RefineViewDelegate {
    func didSelected(tag: Int)
}

protocol RefineViewControllerProtocol {
    func setHeaderView(title: String, color: UIColor)
}

class RefineViewController: UIViewController, RefineViewControllerProtocol{

    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: RefineViewDelegate?
    var presenter: RefineViewPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidload()
        listTableView.delegate = self
        listTableView.dataSource = self
    }

    func setHeaderView(title: String, color: UIColor) {
        headerView.backgroundColor = color
        titleLabel.text = title
    }
}

extension RefineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        let tag = presenter.content(indexPath: indexPath).tag!
        delegate.didSelected(tag: tag)
        dismiss(animated: true, completion: nil)
    }
}

extension RefineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = presenter.content(indexPath: indexPath).taskModel?.taskTitle
        return cell
    }
}
