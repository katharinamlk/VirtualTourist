//
//  CollectionDetailViewCell.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 03.03.21.
//

import UIKit

class CollectionDetailViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if imageView.image != nil {
            activityIndicator.stopAnimating()
        }
    }

}
