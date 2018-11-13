//
//  UserProfileViewController.swift
//  Compass
//
//  Created by Csabi on 06/11/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController {

    let userImage = UIImageView()
    let userInforTextField = UILabel()
    let findUserButton  = UIButton()
    let parse = PServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        setUpHandlers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchUserData()
    }

    private func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
        
        findUserButton.setTitleColor(UIColor.green, for: .normal)
        userInforTextField.numberOfLines = 0
        userInforTextField.sizeToFit()
        userInforTextField.textColor = UIColor.white
        
        userImage.image = UIImage(named: "noavatar.png")
        userImage.contentMode = .scaleAspectFit
        
        let stackView = UIStackView(arrangedSubviews: [userInforTextField, findUserButton])
        stackView.axis = .vertical
        stackView.spacing = 40
    
        self.view.addSubview(userImage)
        self.view.addSubview(stackView)
        userImage.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([userImage.heightAnchor.constraint(equalToConstant: 300),
                                     userImage.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                                     userImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        
        NSLayoutConstraint.activate([stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width-25),
                                     stackView.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                     stackView.topAnchor.constraint(equalTo: userImage.bottomAnchor)])
        
        userImage.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        userImage.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
    }
    
    // Ends Here:
    private func fetchUserData() {
        
        if let userName = UserDefaults.standard.string(forKey: "targetUserName") {
            navigationItem.title = userName
            findUserButton.setTitle("Find " + userName + "'s location", for: .normal)
            
            parse.fetchUserData(userName: userName) { (data, error) in
                guard error == nil else {
                    print (error ?? "default error message")
                    return
                }
                if let uData = data {
                     self.userInforTextField.text = uData.userInfo
                     self.userImage.image = uData.avatar
                }
            }
        }
    }
    // !!! Code to walk through
    // Start Here: Some Code that needs Refactoring -> Go to ParseServer class to see refactoring
    private func fetchUserDataBadPractice() {
        if let userName = UserDefaults.standard.string(forKey:"targetUserName") {
            navigationItem.title = userName
            findUserButton.setTitle("Find " + userName + "'s location", for: .normal)
            
            let query = PFUser.query()
            query?.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error ?? "error while fetching user names")
                } else if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if user.username == userName {
                                if let userInfo = user.value(forKey: "userInfo") as? String {
                                    self.userInforTextField.text = userInfo}
                                if let avatarPic = user.value(forKey: "avatar") as? PFFile {
                                    avatarPic.getDataInBackground { (imageData, error) in
                                        if error == nil {
                                            let image = UIImage(data:imageData!)
                                            self.userImage.image = image
                                        } else{
                                            print(error ?? "error while fetching image")
                                            self.userImage.image = UIImage(named: "noavatar.png")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    private func setUpHandlers() {
        findUserButton.addTarget(self, action: #selector(findUserButtonPressed), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func findUserButtonPressed() {
        self.navigationController?.pushViewController(CompassViewController(), animated: true)
    }
}
