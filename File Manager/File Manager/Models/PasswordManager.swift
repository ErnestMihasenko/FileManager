//
//  PasswordManager.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 19.07.22.
//

import Foundation
import KeychainSwift

class PasswordManager {
    
    static let shared = PasswordManager()
    private let keychain = KeychainSwift()
    weak var delegate: PasswordManagerDelegate?
    
    private init() {}
    
    var hasPassword: Bool {
        keychain.get("Password") != nil
    }
    
    var askedPassword = false
    
    func checkPassword(_ password: String) -> Bool {
        if keychain.get("Password") == password {
            delegate?.didEnterPassword()
            return true
        } else {
            return false
        }
    }
    
    func createPassword(password: String) {
        keychain.set(password, forKey: "Password", withAccess: .accessibleWhenUnlocked)
    }
    
}
