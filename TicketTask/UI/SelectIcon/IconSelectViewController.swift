//
//  ColorSelectViewController.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/28.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

protocol IconSelectViewControllerDelegate {
    func selectedIcon(iconStr: String)
}

protocol IconSelectViewControllerProtocol {

}

class IconSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var presenter: IconSelectViewPresenterProtocol!

    // レイアウト設定　UIEdgeInsets については下記の参考図を参照。
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 30.0, bottom: 15.0, right: 30.0)
    // 1行あたりのアイテム数
    private let itemsPerRow: CGFloat = 3

    private var cells: [UICollectionViewCell]?

    var editTaskVC: EditTaskViewController?

    open weak var delegate: IconSelectViewControllerDelegate?

    @IBOutlet private weak var cellectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Initilizer
    static func initiate(delegate: IconSelectViewControllerDelegate, color: TaskColor) -> IconSelectViewController {
        let viewController = UIStoryboard.instantiateInitialViewController(from: self)
        viewController.presenter = IconSelectViewPresenter(view: viewController, taskColor: color)
        viewController.delegate = delegate
        viewController.modalPresentationStyle = .overFullScreen
        viewController.preferredContentSize = CGSize(width: 200, height: 200)
        // 矢印が出る方向の指定
        viewController.popoverPresentationController?.permittedArrowDirections = .any
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cells = []
        cellectionView.delegate = self
        cellectionView.dataSource = self

        if #available(iOS 13.0, *) {
            let backButtonImage = self.closeButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            self.closeButton.setImage(backButtonImage, for: .normal)
            self.closeButton.tintColor = .dynamicColor
        }

    }

    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let iconImage = cell.viewWithTag(1) as! UIImageView
        iconImage.image = UIImage(named: "icon-\(indexPath.row)")?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = presenter.taskColor.gradationColor1
        cells?.append(cell)
        return cell
    }

    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate!.selectedIcon(iconStr: "icon-\(indexPath.row)")
        dismiss(animated: true, completion: nil)
    }

}

extension IconSelectViewController: IconSelectViewControllerProtocol {

}
