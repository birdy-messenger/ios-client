//
//  ProfileViewControllerHandlers.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 10/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        present(picker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo data: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = data["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = data["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateDataBase() {
        let userID = Auth.auth().currentUser?.uid
        var fileName = userID!
        fileName.append(".png")
        let storageRef = Storage.storage().reference().child(fileName)
        let uploaData = self.profileImageView.image!.pngData()
        
        storageRef.putData(uploaData!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard metadata != nil else {
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let downloadURL = url {
                    let ref = Database.database().reference().child("users").child(userID!)
                    ref.updateChildValues(["profileImageUrl": downloadURL.absoluteString])
                }
            }
        }
    }
}
