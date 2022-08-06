//
//  ViewModeDelegate.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 6.08.22.
//

import Foundation

extension FilesViewController: ViewModeDelegate {
    func switchViewMode(viewMode: ViewMode) {
        switch viewMode {
        case .tableView:
            foldersTableView.isHidden = false
            filesCollectionView.isHidden = true
            
        case .collectionView:
            foldersTableView.isHidden = true
            filesCollectionView.isHidden = false
        }
        currentViewMode = viewMode
        saveViewMode()
    }
}
