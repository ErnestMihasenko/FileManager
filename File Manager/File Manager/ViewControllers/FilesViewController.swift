//
//  ViewController.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 31.05.22.
//

import UIKit
import PhotosUI
import KeychainSwift

class FilesViewController: UIViewController {
    
    @IBOutlet weak var foldersTableView: UITableView!
    
    @IBOutlet weak var filesCollectionView: UICollectionView!
    
    @IBOutlet weak var createFolderButton: UIBarButtonItem!
    
    var manager = ElementsManager()
    
    let keychain = KeychainSwift()
    
    var currentViewMode = ViewMode.tableView
    
    let currentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    let delegate = TableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPassword()
        
        manager.viewModeDelegate = self
        manager.delegate = self
        
        setUpTableView()
        setupCollectionView()
        
        foldersTableView.register(UINib(nibName: "FolderViewCell", bundle: nil),
                                  forCellReuseIdentifier: TableViewCell.id)
        
        setUpNavigationBar()
        getViewMode()
        requestNotificationsPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PasswordManager.shared.delegate = self
    }
    
    private func getViewMode() {
        let viewModeRaw = UserDefaults.standard.integer(forKey: "ViewMode")
        let viewMode = ViewMode(rawValue: viewModeRaw) ?? .collectionView
        switchViewMode(viewMode: viewMode)
    }
    
    private func setUpNavigationBar() {
        let rightBarButtonItem = UIBarButtonItem(title: "Menu", image: nil, primaryAction: nil, menu: actionsMenu)
        
        let editButton = UIBarButtonItem(systemItem: .edit, primaryAction: UIAction(handler: { _ in
            self.manager.switchMode(.edit)
        }))
        
        let switchModeButton = UIBarButtonItem(title:"", image: UIImage(systemName: "perspective"), primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            let newViewMode: ViewMode
            switch self.currentViewMode {
            case .tableView:
                newViewMode = .collectionView
            case .collectionView:
                newViewMode = .tableView
            }
            self.switchViewMode(viewMode: newViewMode)
        }))
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, editButton, switchModeButton]
    }
    
    private func addEditModeRightButtons() {
        let selectButton = UIBarButtonItem(systemItem: .cancel,
                                           primaryAction: UIAction(handler: { _ in
            self.manager.switchMode(.view)
        }))
        
        let deleteButton = UIBarButtonItem(systemItem: .trash,
                                           primaryAction: UIAction(handler: { _ in
            self.manager.deleteSelectedElements()
        }))
        
        navigationItem.rightBarButtonItems = [selectButton, deleteButton]
    }
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Create folder", image: UIImage(systemName: "folder.fill"), handler: { (_) in self.createFolderAlert()
            }),
            UIAction(title: "Upload picture", image: UIImage(systemName: "plus.rectangle.on.rectangle"), handler: {_ in
                self.uploadImage()
            }),
            UIAction(title: "Delete..", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                self.manager.switchMode(.edit)
            }),
            UIAction(title: "Change password", image: UIImage(systemName: "key"), handler: {_ in
                self.createPasswordAlert(title: "Change password", message: "Create new password")
            })
        ]
    }
    
    var actionsMenu: UIMenu {
        return UIMenu(title: "Menu", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    private func createFolderAlert() {
        
        let createFolderAlert = UIAlertController(title: "Create new folder",
                                                  message: "Enter folder name",
                                                  preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let createFolderAction = UIAlertAction(title: "Save", style: .default) { [self]_ in
            
            guard let folderName = createFolderAlert.textFields?.first?.text,
                  !folderName.isEmpty else {
                      self.createFolderAlert()
                      
                      return
                  }
            self.manager.createElement(type: .folder, name: folderName)
        }
        
        createFolderAlert.addTextField { textField in textField.placeholder = "Folder name" }
        
        createFolderAlert.addAction(cancelAction)
        createFolderAlert.addAction(createFolderAction)
        
        present(createFolderAlert, animated: true)
    }
    
    private func uploadImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.allowsEditing = true
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    func saveViewMode() {
        UserDefaults.standard.set(currentViewMode.rawValue, forKey: "ViewMode")
    }
    
    func createPasswordAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var passwordTextField: UITextField?
        
        let enterAction = UIAlertAction(title: "Enter", style: .default) { _ in
            if ((passwordTextField?.hasText) != nil) {
                PasswordManager.shared.createPassword(password: passwordTextField?.text ?? "")
            } else {
                return
            }
        }
        
        alertController.addAction(enterAction)
        alertController.addTextField { passwordField in
            passwordField.placeholder = "Password"
            passwordTextField = passwordField
        }
        present(alertController, animated: true)
    }
    
    func getPasswordAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var passwordTextField: UITextField?
        
        let enterAction = UIAlertAction(title: "Enter", style: .default) { _ in
            if PasswordManager.shared.checkPassword(passwordTextField?.text ?? "") {
                PasswordManager.shared.askedPassword = true
                alertController.dismiss(animated: true)
            }
            else {
                self.getPasswordAlert(title: "Wrong password", message: "Try again")
            }
        }
        
        alertController.addAction(enterAction)
        alertController.addTextField { passwordField in
            passwordField.placeholder = "Password"
            passwordTextField = passwordField
        }
        present(alertController, animated: true)
    }
    
    func checkPassword() {
        if PasswordManager.shared.hasPassword {
            guard !PasswordManager.shared.askedPassword else { return }
            getPasswordAlert(title: "Welcome back", message: "Enter password")
        } else {
            createPasswordAlert(title: "Welcome", message: "Create new password")
        }
    }
    
    private func requestNotificationsPermissions() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { sucess, error in
                print("Notifications success:", sucess)
                
                self.sendMorningNotification()
                self.sendTenMinutesNotification()
                self.removeObserver()
                self.addObserver()
            }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(sendTenMinutesNotification), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc private func sendTenMinutesNotification() {
        
        let content = UNMutableNotificationContent()
        content.body = "You didn't use File Manager for 10 minutes! Please come back"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
    }
    
    private func sendMorningNotification() {
        
        let content = UNMutableNotificationContent()
        content.body = "Good Morning!"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func updateNavigationButtons() {
        switch manager.mode {
        case .edit:
            addEditModeRightButtons()
            
        case .view:
            setUpNavigationBar()
        }
    }
}
