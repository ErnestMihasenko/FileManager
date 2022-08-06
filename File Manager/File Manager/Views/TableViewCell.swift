//
//  FolderViewCell.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 1.06.22.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    static let id = "FolderViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateData(element: Element) {
        updateImage(element: element)
        
        self.label.text = element.name
    }
    
    private func updateImage(element: Element) {
        let image: UIImage?
        
        switch element.type {
        case .folder:
            image = UIImage(systemName: "folder.fill")
            
        case .image:
            guard let data = try? Data(contentsOf: element.path) else {
                return
            }
            
            image = UIImage(data: data)
        }
        self.elementImageView.image = image
    }
}
