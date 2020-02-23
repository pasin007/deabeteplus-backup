//
//  AddProfileViewController.swift
//  deabeteplus
//
//  Created by pasin on 11/1/2563 BE.
//  Copyright © 2563 Ji Ra. All rights reserved.
//

import UIKit

class AddProfileViewController: UIViewController, BaseViewController {

    let picker: UIImagePickerController = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
       
    let imageViewModel: ImageViewModel = ImageViewModel()
    let userViewModel: UserViewModel = UserViewModel()
    
    private var selectImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

/// MARK: Function
extension AddProfileViewController {
    
    // STEP: 4 click add profile
    @IBAction func dpUploadImage() {
        guard let image = selectImage else {
            doAddProffile()
            return
        }
        imageViewModel.uploadImage(image, path: "profile", onSuccess: { (url) in
            self.doAddProffile("\(url.absoluteString)")
        }) { (_) in
            
        }
    }
    
    // STEP: 5 call api
    private func doAddProffile(_ url: String? = nil) {
        guard let id = UserManager.shared.userId,
            let name = nameTextField.text,
            let phone = phoneTextField.text,
            !name.trim.isEmpty, !phone.trim.isEmpty else { return }
        var parms: [String : Any] = [
            "user_id" : id,
            "type_id" : 2,
            "name" : name,
            "phone" : phone
        ]
        if let image = url {
            parms["image"] = image
        }
        userViewModel.addProfile(parms, onSuccess: { [weak self] (userProfile) in
            UserManager.shared.currentUser?.currentProfile = userProfile
            UserManager.shared.currentUser?.profiles.append(userProfile)
            self?.dismiss(animated: true)
        }) { (err) in
            print("err : \(err?.localizedDescription ?? "")  ")
        }
    }
    
    // STEP: 1
    @IBAction func openPickerAction() {
        // เลือก option รูป
        let alert: UIAlertController = UIAlertController(title: "Select Action", message: nil, preferredStyle: .actionSheet)
        
        // camera action
        let cameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (_) in
            self?.openCamera()
        }
        alert.addAction(cameraAction)
        
        
         // photo Library action
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] (_) in
            self?.openPhotoLibrary()
        }
        
        alert.addAction(photoLibraryAction)
        
        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) )
        
        present(alert, animated: true)
    }
    
    // STEP: 2
    private func openCamera() {
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    // STEP: 2
    private func openPhotoLibrary() {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction func closeView() {
        dismiss(animated: true)
    }
    
}

extension AddProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // STEP: 3
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // ทำงานหลังจากเลือกรูปเสร็จ
        
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        selectImage = image
        
        // ปิดหน้าเลือกรูป
        dismiss(animated: true)
    }
}
