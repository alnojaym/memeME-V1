//
//  ViewController.swift
//  memeMe
//
//  Created by Mubarak Alnujaym on 03/02/1441 AH.
//  Copyright © 1441 Mubarak Alnujaym. All rights reserved.
//

import UIKit
import Foundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var buttomTextField: UITextField!
    @IBOutlet weak var buttomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var pickFromCamira: UIBarButtonItem!
    @IBOutlet weak var pickFromAlbom: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var memeImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -3.50,]
        configureUITextField(textField: topTextField, text: "TOP", defaultAttributes: memeTextAttributes)
        configureUITextField(textField: buttomTextField, text: "BOTTOM", defaultAttributes: memeTextAttributes)
        shareButton.isEnabled = false
    }
    
    func configureUITextField(textField: UITextField, text: String, defaultAttributes: [NSAttributedString.Key: Any]) {
        textField.defaultTextAttributes = defaultAttributes 
        textField.delegate = self
        textField.text = text //"TOP" or "BOTTOM"
        textField.textAlignment = .center
        textField.backgroundColor = .clear
        textField.autocapitalizationType = .allCharacters
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickFromCamira.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
       subscribeToKeyboardNotifications()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //clear when editing top or bottom text field
        textField.text = ""
        if textField == topTextField {
             //unsubscribe to keyboard notification when editing top text field
             unsubscribeFromKeyboardNotifications()
        } else {
             //subscribe when editing to bottom text field
             subscribeToKeyboardNotifications()
        }
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    func save() {
        // Create the meme
        _ = Meme(topText: topTextField.text!, bottomText: buttomTextField.text!, originalImage: pickFromAlbom.image!, memedImage: generateMemedImage())
    }
    
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        buttomToolbar.isHidden = true
        topToolbar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        buttomToolbar.isHidden = false
        topToolbar.isHidden = false
        return memedImage
    }
    
    func pickAnImage(_ source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            memeImageView.image = image
            topTextField.topAnchor.constraint(equalTo:memeImageView.topAnchor, constant: +30).isActive = true
            buttomToolbar.bottomAnchor.constraint(equalTo: memeImageView.bottomAnchor, constant: -30).isActive = true
        }
        
        shareButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
     }
     
     //MARK: Keyboard adjusments
     @objc func keyboardWillShow(_ notification:Notification) {
         if buttomTextField.isFirstResponder {
             view.frame.origin.y = getKeyboardHeight(notification) * (-1)
         }
     }
     
     @objc func keyboardWillHide(_ notification:Notification) {
         
         view.frame.origin.y = 0
     }
     
     func getKeyboardHeight(_ notification:Notification) -> CGFloat {
         
         let userInfo = notification.userInfo
         let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
         return keyboardSize.cgRectValue.height
     }
     
     //MARK: Notification
     func subscribeToKeyboardNotifications() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     
     func unsubscribeFromKeyboardNotifications() {
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }
    
    
     @IBAction func shareMeme(_ sender: Any) {
           let meme = generateMemedImage()
           let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
           present(controller, animated: true, completion: nil)
           controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
               if completed == true{
                   self.save()
               }
           }
       }
    

    
       func hideToolbars(_ value: Bool) {
         topToolbar.isHidden = value
         buttomToolbar.isHidden = value

     }
    
    
     //MARK: Actions
     @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        self.pickAnImage(.photoLibrary)
     }
     
     @IBAction func pickAnImageFromCamera(_ sender: Any) {
        self.pickAnImage(.camera)
     }
    
     @IBAction func cancelImage(_ sender: Any) {
         pickFromAlbom.image = nil
         topTextField.text = "TOP"
         buttomTextField.text = "BOTTOM"
         shareButton.isEnabled = false
     }
     }

