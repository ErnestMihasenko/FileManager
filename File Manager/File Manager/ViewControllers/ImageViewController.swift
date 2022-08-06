//
//  ImageViewController.swift
//  File Manager
//
//  Created by Ernest Mihasenko on 6.07.22.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
