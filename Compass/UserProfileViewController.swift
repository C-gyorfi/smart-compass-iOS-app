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

    let userImage = UIImageView(image: UIImage(named: "avatar.png"))
    let userInforTextField = UILabel()
    let findUserButton  = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createUI()
        setUpHandlers()
    }

    private func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
        
        findUserButton.titleLabel?.textColor = UIColor.cyan
        userInforTextField.numberOfLines = 0
        userInforTextField.sizeToFit()
        userInforTextField.textColor = UIColor.white
        
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
                                self.userInforTextField.text = user.value(forKey: "userInfo") as! String
                                if let avatarPic = user.value(forKey: "avatar") as? PFFile {
                                    avatarPic.getDataInBackground { (imageData, error) in
                                        if error == nil {
                                            let image = UIImage(data:imageData!)
                                            self.userImage.image = image
                                        }else{
                                            print(error ?? "error while fetching image")
                                            self.userImage.image = UIImage(named: "avatar.png")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
            
        }
        
        let stackView = UIStackView(arrangedSubviews: [userImage, userInforTextField, findUserButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width-25),
                                     stackView.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                     stackView.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor)])
        
        NSLayoutConstraint.activate([userImage.heightAnchor.constraint(equalToConstant: 300)])
  
        NSLayoutConstraint.activate([userInforTextField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
                                     userInforTextField.heightAnchor.constraint(equalToConstant: 200)])
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
