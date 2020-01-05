//
//  ImageViewController.swift
//  deabeteplus
//
//  Created by Ji Ra on 1/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, BaseViewController {

    let picker: UIImagePickerController = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    
    let viewModel: ImageViewModel = ImageViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
 

/// MARK: Function
extension ImageViewController {
    
    @IBAction func openPickerAction() {
        let alert: UIAlertController = UIAlertController(title: "Select Action", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (_) in
            self?.openCamera()
        }
        alert.addAction(cameraAction)
        
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] (_) in
            self?.openPhotoLibrary()
        }
        
        alert.addAction(photoLibraryAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) )
        
        present(alert, animated: true)
    }
    
    private func openCamera() {
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    private func openPhotoLibrary() {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction func closeView() {
        dismiss(animated: true)
    }
    
    @IBAction func uploadImage() {
        guard let image = imageView.image else { return }
        viewModel.uploadImage(image, path: "tests", onSuccess: { (imageUrl) in
            print("\(imageUrl)")
        }) { (error) in
            print(error ?? "")
        }
    }
}

extension ImageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        
        dismiss(animated: true)
    }
}
