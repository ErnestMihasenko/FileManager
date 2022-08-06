//
//  FolderSection.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 2.06.22.
//

import Foundation

struct Element: Equatable {
    let name: String
    let path: URL
    
    let type: ElementType
}

enum ElementType {
    case folder
    case image
}
