//
//  ImagePicker.swift
//  bookudo
//
//  Created by Kutay Agbal on 4.02.2023.
//

import Foundation
import AVFoundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [HashableImage]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(images: $images)
    }
    
    class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var images: [HashableImage]
        
        init(images: Binding<[HashableImage]>) {
            _images = images
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            images.append(HashableImage(image: uiImage, id: UUID(), pageNo: nil, objectID: nil))
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
