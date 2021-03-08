//
//  CollectionDetailView.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 07.03.21.
//

import Foundation
import UIKit

extension CollectionDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionDetailViewCell", for: indexPath) as! CollectionDetailViewCell
        let cellimage = fetchedImages[indexPath.row]
            cell.imageView.image = cellimage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fetchedImages.remove(at: indexPath.row)
        deletePhoto(indexPath)
    }
    
}
