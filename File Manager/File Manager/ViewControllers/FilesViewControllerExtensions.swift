//
//  Extensions.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 1.06.22.
//

import Foundation
import UIKit
import PhotosUI
import UserNotifications

extension FilesViewController: UITableViewDelegate {
    
    func setUpTableView() {
        foldersTableView.delegate = self
        foldersTableView.dataSource = self
        foldersTableView.allowsMultipleSelectionDuringEditing = true
        foldersTableView.register(TableViewCell.classForCoder(),
                                  forCellReuseIdentifier: TableViewCell.id)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            manager.selectElement(manager.elements[indexPath.row])
            return
        }
        handleCellTap(index: indexPath.row)
    }
    
    func handleCellTap(index: Int) {
        let element = manager.elements[index]
        
        switch element.type {
        case .folder:
            navigateToNextFolder(element.path)
            
        case .image:
            
            guard let imageViewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else { return }
            
            guard let data = try? Data(contentsOf: element.path) else {
                return
            }
            
            imageViewController.image = UIImage(data: data)
            
            present(imageViewController, animated: true, completion: nil)
            
        }
    }
    
    func navigateToNextFolder(_ url: URL) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilesViewController") as? FilesViewController else {
            return
        }
        
        viewController.manager.currentDirectory = url
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension FilesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard PasswordManager.shared.askedPassword else { return 0 }
        return manager.elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = manager.elements[indexPath.row]
        
        switch element.type {
        case .folder, .image:
            return getDirectoryCell(tableView, element: element)
        }
    }
    
    private func getDirectoryCell(_ tableView: UITableView, element: Element) -> UITableViewCell {
        guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else {
            return UITableViewCell()
        }
        
        tableViewCell.updateData(element: element)
        
        return tableViewCell
    }
}

extension FilesViewController: ElementsManagerDelegate {
    func handleModeChange() {
        updateNavigationButtons()
        foldersTableView.isEditing = manager.mode == .edit
        filesCollectionView.isEditing = manager.mode == .edit
        reloadData()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.foldersTableView.reloadData()
            self.filesCollectionView.reloadData()
        }
    }
}

extension FilesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage,
              let imageName = (info[.imageURL] as? URL)?.lastPathComponent else {
                  return
              }
        
        manager.createImage(image, name: imageName)
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
        
        picker.dismiss(animated: true)
    }
}

extension FilesViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {  image, error in
                if let image = image as? UIImage {
                    self.manager.createImage(image, name: "testImage")
                    
                }
            }
        }
        picker.dismiss(animated: true)
    }
}

