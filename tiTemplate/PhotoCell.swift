//
//  PhotoCell.swift
//  Interior
//
//  Created by Petr Gusakov on 25/07/2019.
//  Copyright © 2019 Petr Gusakov. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var markButton: DeleteButton!
    @IBOutlet var deleteButton: DeleteButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var selectedView: UIImageView!
}

class DeleteButton: UIButton {
    
    var identifier : String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
