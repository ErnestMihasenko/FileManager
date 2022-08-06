//
//  ElementCollectionViewCell.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 19.06.22.
//

import UIKit

class ElementCollectionViewCell: UICollectionViewCell, TestProtocol {
    func updateData(element: Element, selected: Bool) {
        
    }
    
    static let id = "ElementCollectionViewCell"
    
    var elementImageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        createElements()
    }
    
    private func createElements() {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.distribution = .fill
        verticalStack.spacing = 5
        
        addSubview(verticalStack)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            verticalStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            verticalStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 1)
        ])
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        self.elementImageView = imageView
        verticalStack.addArrangedSubview(imageView)
        
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.textAlignment = .center
        self.label = label
        
        verticalStack.addArrangedSubview(label)
        
        let blueView = UIView(frame: bounds)
        blueView.backgroundColor = .blue
        selectedBackgroundView = blueView
    }
}

protocol TestProtocol: AnyObject {
    var elementImageView: UIImageView! { get }
    var label: UILabel! { get }
    
    var backgroundColor: UIColor? { get set }
    
    func updateData(element: Element, selected: Bool)
}

extension TestProtocol {
    func updateData(element: Element) {
        updateImage(element: element)
        
        self.label.text = element.name
    }
    
    private func updateImage(element: Element) {
        let image: UIImage?
        var cornerRadius: CGFloat = 0
        switch element.type {
        case .folder:
            image = UIImage(systemName: "folder.fill")
            elementImageView.contentMode = .scaleAspectFit
            
        case .image:
            guard let data = try? Data(contentsOf: element.path) else {
                return
            }
            cornerRadius = 12
            image = UIImage(data: data)
            elementImageView.contentMode = .scaleAspectFill
        }
        elementImageView.layer.cornerRadius = cornerRadius
        elementImageView.image = image
    }
}
