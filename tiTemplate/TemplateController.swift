//
//  TemplateController.swift
//  tiTemplate
//
//  Created by Petr Gusakov on 19.10.2020.
//

import UIKit
import Photos

class TemplateController: UIViewController, PhotoListDelegate {

    @IBOutlet var leftView: UIView!
    @IBOutlet var rigchtView: UIView!
    @IBOutlet var animButton: UIBarButtonItem!
    
    var tapView = TapView.none
    var isLeftLoaded = false
    var isRightLoaded = false
    var leftImage: UIImage?
    var rightImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.animButton.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: self.view)
        
        if leftView.frame.contains(touchPoint) {
            print("leftView")
            self.tapView = .left
        }
        if rigchtView.frame.contains(touchPoint) {
            print("rigchtView")
            self.tapView = .right
        }
        
        if self.tapView != .none {
            self.performSegue(withIdentifier: "photo", sender: self)
        }
    }

    // MARK: - PhotoListDelegate
    func didSelectPhotoName(localIdentifier: String) {
        //let originalImageName = localIdentifier
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)

        PHImageManager.default().requestImage(for: fetchResult.object(at: 0) , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions) {
                (image, _) in
        
            let imageView = UIImageView(image: image)
            switch self.tapView {
            case .left:
                imageView.frame = self.leftView.frame
                self.leftImage = image
                self.isLeftLoaded = true
            case .right:
                imageView.frame = self.rigchtView.frame
                self.rightImage = image
                self.isRightLoaded = true
            default:
                break
            }

            self.tapView = .none
            
            if self.isRightLoaded && self.isLeftLoaded {
                DispatchQueue.main.async {
                    self.animButton.isEnabled = true
                }
            }
            
            DispatchQueue.main.async {
                self.view.addSubview(imageView)
                self.view.bringSubviewToFront(imageView)
            }
        }
    }

    func didMultiSelectPhotoName(identifierList: [String]) {
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photo" {
            let photoListController = segue.destination as! PhotoListController
            photoListController.widthScreen = self.view.bounds.width
            photoListController.delegate = self
        }
        if segue.identifier == "animation" {
            let animateController = segue.destination as! AnimateController
            animateController.imageList = [self.leftImage!, self.rightImage!]
            animateController.widthScreen = self.view.bounds.width
        }
    }
    

}

enum TapView {
    case left
    case right
    case none
}
