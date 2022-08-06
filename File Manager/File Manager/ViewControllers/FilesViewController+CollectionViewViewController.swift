//
//  FilesViewController+CollectionViewViewController.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 18.06.22.
//

import UIKit

extension FilesViewController: UICollectionViewDelegate {
    var collectionViewCell: String {
        "cell"
    }
    
    func setupCollectionView() {
        filesCollectionView.delegate = self
        filesCollectionView.dataSource = self
        filesCollectionView.allowsMultipleSelectionDuringEditing = true
        filesCollectionView.allowsSelectionDuringEditing = true
        filesCollectionView.register(ElementCollectionViewCell.self, forCellWithReuseIdentifier: ElementCollectionViewCell.id)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !collectionView.isEditing else {
            manager.selectElement(manager.elements[indexPath.item])
            return
        }
        handleCellTap(index: indexPath.item)
    }
}

extension FilesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsCount = 3
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let interitemSpacing = layout?.minimumInteritemSpacing ?? 0
        let leadingSpacing = layout?.sectionInset.left ?? 0
        let trailingSpacing = layout?.sectionInset.right ?? 0
        let sideSpacing = leadingSpacing + trailingSpacing
        let interItemSpacings = interitemSpacing * CGFloat(itemsCount - 1)
        let maxWidth = collectionView.frame.size.width - sideSpacing - interItemSpacings
        let width = maxWidth / CGFloat(itemsCount)
        return CGSize(width: width, height: width)
    }
}

extension FilesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard PasswordManager.shared.askedPassword else { return 0 }
        
        return manager.elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ElementCollectionViewCell.id, for: indexPath) as? ElementCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let element = manager.elements[indexPath.row]
        
        collectionViewCell.updateData(element: element)
                
        return collectionViewCell
    }
}
