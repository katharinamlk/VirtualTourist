//
//  ImagePicker.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 07.03.21.
//

import Foundation
import UIKit

extension CollectionDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addPhoto(image: chosenImage)
            setUpFetchedResultsController()
        } else {
            print("Can not load image from library")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func pickImage(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
}
