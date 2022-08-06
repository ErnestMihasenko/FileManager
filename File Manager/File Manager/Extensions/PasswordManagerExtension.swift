//
//  PasswordManagerExtension.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 6.08.22.
//

import Foundation

extension FilesViewController: PasswordManagerDelegate {
    func didEnterPassword() {
        reloadData()
    }
}
