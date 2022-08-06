//
//  ElemetsManager.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 4.06.22.
//

import Foundation
import UIKit
import KeychainSwift

class ElementsManager {
    
    var mode: Mode = .view {
        didSet {
            delegate?.handleModeChange()
        }
    }
    
    var selectedElements = [Element]()
    var elements = [Element]()
    
    let keychain = KeychainSwift()
    
    var currentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        didSet {
            reloadFolderContents()
        }
    }
    
    var delegate: ElementsManagerDelegate?
    var viewModeDelegate: ViewModeDelegate?
    
    init() {
        reloadFolderContents()
    }
    
    private func reloadFolderContents() {
        guard let currentDirectory = self.currentDirectory,
              let filesUrls = try? FileManager.default.contentsOfDirectory(at: currentDirectory,
                                                                           includingPropertiesForKeys: nil) else {
                  return
              }
        
        self.elements = filesUrls.compactMap {
            let name = $0.lastPathComponent
            guard !name.starts(with: ".") else { return nil }
            let type: ElementType = name.contains(".png") || name.contains(".jpeg") ? .image : .folder
            
            return Element(name: name,
                           path: $0,
                           type: type)
        }
        
        delegate?.reloadData()
    }
    
    func createElement(type: ElementType, name: String) {
        switch type {
        case .folder:
            createFolder(name: name)
            
        default:
            break
        }
        reloadFolderContents()
    }
    
    private func createFolder(name: String) {
        guard let currentDirectory = currentDirectory else {
            return
        }
        var name = name
        while name.hasPrefix(".") {
            name.removeFirst()
        }
        let newFolderPath = currentDirectory.appendingPathComponent(name)
        
        try? FileManager.default.createDirectory(at: newFolderPath,
                                                 withIntermediateDirectories: false,
                                                 attributes: nil)
        
        reloadFolderContents()
    }
    
    func createImage(_ image: UIImage, name: String) {
        guard let currentDirectory = self.currentDirectory,
              let data = image.jpegData(compressionQuality: 1) else {
                  return
              }
        
        let newImagePath = currentDirectory.appendingPathComponent(name)
        
        try? data.write(to: newImagePath)
        
        reloadFolderContents()
    }
    
    func switchMode(_ mode: Mode) {
        self.mode = mode
        
        switch mode {
        case .view:
            self.selectedElements = []
            
        case .edit:
            break
        }
    }
    
    func selectElement(_ element: Element) {
        guard mode == .edit else { return }
        
        if let index = selectedElements.firstIndex(of: element) {
            selectedElements.remove(at: index)
        }
        else {
            selectedElements.append(element)
        }
        print(selectedElements)
    }
    
    func deleteSelectedElements() {
        guard mode == .edit else { return }
        
        for element in selectedElements {
            try? FileManager.default.removeItem(at: element.path)
        }
        switchMode(.view)
        
        reloadFolderContents()
    }
}
