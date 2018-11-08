//
//  AccountSettingsViewController.swift
//  Compass
//
//  Created by Csabi on 24/10/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import UIKit
import Parse

class AccountSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let deleteAccountButton = UIButton()
    let updateUserImageButton = UIButton()
    let par = PServer()
    let userData = UserData()
    var activityIndicator = UIActivityIndicatorView()
    let nameLabel = UILabel()
    let nameTextField = UITextField()
    let aboutLabel = UILabel()
    var avatarImage = UIImageView()
    let userInforTextField = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        setUpHandlers()
        
        guard let userName = UserDefaults.standard.string(forKey: "UserName") else {
            print("ERROR current user doesnt exist")
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.userData.name = userName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
        navigationItem.title = "Account Settings"
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUserDetails))
        self.navigationItem.rightBarButtonItem  = saveButton
        updateUserImageButton.setTitle("select your picture", for: .normal)
        updateUserImageButton.setTitleColor(UIColor.blue, for: .normal)
     
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.setTitleColor(UIColor.red, for: .normal)
        
        nameLabel.text = "Name:"
        nameLabel.textColor = UIColor.white
        nameTextField.backgroundColor = UIColor.lightGray
        nameTextField.placeholder = "choose a nickname..."
        
        userInforTextField.backgroundColor = UIColor.lightGray
        userInforTextField.text = "Welcome to my profile..."
        aboutLabel.text = "About:"
        aboutLabel.textColor = UIColor.white
        
        self.avatarImage = UIImageView(image: UIImage(named: "noavatar.png"))
        
        loadCurrentUserData()
        
        let nameRowsStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
        nameRowsStackView.axis = .vertical
        nameRowsStackView.spacing = 10
        
        let topStackView = UIStackView(arrangedSubviews: [avatarImage, nameRowsStackView])
        topStackView.axis = .horizontal
        topStackView.spacing = 10
        
        let stackView = UIStackView(arrangedSubviews: [updateUserImageButton, topStackView, aboutLabel, userInforTextField, deleteAccountButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        self.view.addSubview(stackView)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width-25),
                                     stackView.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                     stackView.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor)])
        
        NSLayoutConstraint.activate([avatarImage.heightAnchor.constraint(equalToConstant: 80),
                                     avatarImage.widthAnchor.constraint(equalToConstant: 80)])

        NSLayoutConstraint.activate([updateUserImageButton.heightAnchor.constraint(equalToConstant: 10),
                                     updateUserImageButton.widthAnchor.constraint(equalToConstant: 10)])
        
        NSLayoutConstraint.activate([userInforTextField.heightAnchor.constraint(equalToConstant: 200)])
    }
    
    private func setUpHandlers() {
        deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        updateUserImageButton.addTarget(self, action: #selector(updateUserImage), for: .touchUpInside)
    }
    
    @objc private func deleteAccount() {
        
        let alert = UIAlertController(title: "Account will be deleted", message: "Do you wish to continue?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
            
            self.activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let query = PFQuery(className: "Locations")
     
            query.whereKey("UserName", equalTo: PFUser.current()?.username)
                query.findObjectsInBackground { (objects, error) in
                    if let error = error {
                        print(error)
                    } else if let object = objects?.first {
                        
                        if let obj = object as? PFObject {
                            print("Deleting: \(obj)")
                            obj.deleteInBackground(block: { (success, error) in
                                if error != nil {
                                    print(error ?? "error while deleting")
                                } else {
                                    PFUser.current()?.deleteInBackground(block: { (success, error) in
                                        guard error == nil else {
                                            var displayErrorMessage = "Error while deleting account, please try again"
                                            let error = error as NSError?
                                            if let errorMessage = error?.userInfo["error"] as? String {
                                                displayErrorMessage = errorMessage
                                            }
                                            self.createAlert(title: "Error:", message: displayErrorMessage)
                                            return
                                        }
                                        if success {
                                            PFUser.logOut()
                                            UserDefaults.standard.removeObject(forKey: "locationObjectId")
                                            UserDefaults.standard.removeObject(forKey: "userName")
                                            self.activityIndicator.stopAnimating()
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    })
                                    print("Object deleted")}
                            })
                        }
                    }
                }
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func loadCurrentUserData() {
        self.nameTextField.text = PFUser.current()?.username
        if let userInfo = PFUser.current()?.value(forKey: "userInfo") {
            self.userInforTextField.text = userInfo as! String }
        
        if let avatarPic = PFUser.current()!.value(forKey: "avatar") as? PFFile {
            avatarPic.getDataInBackground { (imageData, error) in
                if error == nil {
                   if let image = UIImage(data:imageData!) {
                        self.avatarImage.image = image }
                }else{
                    print(error ?? "error while fetching image")
                }
            }
        }
    }
    
    @objc func updateUserImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let compressedImage = UIImageJPEGRepresentation(image, 0.2)
            self.avatarImage.image = UIImage(data:compressedImage!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveUserDetails(){
        
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let user = PFUser.current()
        let imageData = UIImageJPEGRepresentation(self.avatarImage.image!, 0.1)
        let imageFile = PFFile(name: "avatar.png", data: imageData!)
        user!["avatar"] = imageFile
        user!.username = nameTextField.text
        user!["userInfo"] = userInforTextField.text
        user?.saveInBackground(block: { (success, error) in
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                var displayErrorMessage = "Please try again later"
                let error = error as NSError?
                if let errorMessage = error?.userInfo["error"] as? String {
                    displayErrorMessage = errorMessage
                }
                
                self.createAlert(title: "Error:", message: displayErrorMessage)
                return
            }
            if success {
                if let id = UserDefaults.standard.string(forKey: "locationObjectId") {
                    self.par.updateUserLocation(classN: "Locations", id: id, location: nil)
                }
                print(LoginViewController().userData.objectID)
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        userInforTextField.resignFirstResponder()
    }
    
}
