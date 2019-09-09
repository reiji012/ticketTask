//
//  ColorSelectViewController.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/28.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import UIKit

class IconSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // レイアウト設定　UIEdgeInsets については下記の参考図を参照。
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 30.0, bottom: 15.0, right: 30.0)
    // 1行あたりのアイテム数
    private let itemsPerRow: CGFloat = 3
    
    private var cells: [UICollectionViewCell]?
    
    var editTaskVC: EditTaskViewController?
    
    open var delegate: TaskEditDalegate?
    
    @IBOutlet weak var cellectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = []
        cellectionView.delegate = self
        cellectionView.dataSource = self
    }
    
    
    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let iconImage = cell.viewWithTag(1) as! UIImageView
        iconImage.image = UIImage(named: "icon-\(indexPath.row)")?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = self.editTaskVC?.currentColor
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
        delegate!.selectedIcon(icon: (UIImage(named: "icon-\(indexPath.row)")?.withRenderingMode(.alwaysTemplate))!, iconStr: "icon-\(indexPath.row)")
        dismiss(animated: true, completion: nil)
    }
    
}
