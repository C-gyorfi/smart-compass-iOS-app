//
//  LoginViewController.swift
//  Compass
//
//  Created by Csabi on 08/10/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    var isloginPage = true
    var activityIndicator = UIActivityIndicatorView()
    
    let titleLabel = UILabel(frame: CGRect.zero)
    let nameTextField = UITextField(frame: CGRect.zero)
    let passTextField = UITextField(frame: CGRect.zero)
    let loginButton = UIButton(frame: CGRect.zero)
    let switchPageButton = UIButton(frame: CGRect.zero)
    let par = PServer()
    public let userData = UserData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        par.initParse(appID: "492795c6ea25112881915677092fb19d95f43ce0", clKey: "6c4448eb0dc5d344a0ca35f8d8f978ff82b76028", serverAddress: "http://18.188.82.67:80/parse")
        
        createUI()
    }
    
    private func createUI() {
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
        self.view.backgroundColor = UIColor.darkGray
        
        titleLabel.textColor = UIColor.red
        
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        
        switchPageButton.setTitle("Not registered? SignUp", for: .normal)
        switchPageButton.addTarget(self, action: #selector(SwitchPagePressed), for: .touchUpInside)
        
        nameTextField.text = "test@mail.co.uk"
        nameTextField.textColor = UIColor.white
        nameTextField.layer.backgroundColor = UIColor.blue.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: "e-mail address...", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        
        passTextField.placeholder = "password..."
        passTextField.text = "pass"
        passTextField.textColor = UIColor.white
        passTextField.isSecureTextEntry = true
        passTextField.layer.backgroundColor = UIColor.blue.cgColor
        passTextField.attributedPlaceholder = NSAttributedString(string: "Password...", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, nameTextField, passTextField, loginButton, switchPageButton])
        stackView.axis = .vertical
        stackView.spacing = 10;
        
        if isloginPage {
            navigationItem.title = "Login Page"
            loginButton.setTitle("Login", for: .normal)
            switchPageButton.setTitle("Go to Signup page", for: .normal)
            
        } else {
            navigationItem.title = "Signup Page"
            loginButton.setTitle("Signup", for: .normal)
            switchPageButton.setTitle("Go to Login page", for: .normal)
        }
        
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.widthAnchor.constraint(equalToConstant: 200),
                                     stackView.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                     stackView.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            let viewController = UserTableViewController(parseServer: par)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func loginButtonPressed() {
        
        guard let name = nameTextField.text, name.count > 0,
            let password = passTextField.text, password.count > 0 else {
                createAlert(title: "Invalid username or password format", message: "Please enter valid username or password")
                return
        }

        guard isValidEmail(testStr: nameTextField.text!) else {
            createAlert(title: "Invalid e-mail address", message: "Please enter valid e-mail")
            return
        }
            activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        
        if isloginPage {
            
            //clear previous login data
            UserDefaults.standard.removeObject(forKey: "locationObjectId")
            PFUser.logInWithUsername(inBackground: nameTextField.text!, password: passTextField.text!) { (user, error) in
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()

                if error != nil {

                    var displayErrorMessage = "Please try again later"
                    let error = error as NSError?
                    if let errorMessage = error?.userInfo["error"] as? String {

                        displayErrorMessage = errorMessage

                    }
                    self.createAlert(title: "Error:", message: displayErrorMessage)
                } else {
                    self.userData.name = self.nameTextField.text!
                    self.userData.location = CLLocation(latitude: 0, longitude: 0)

                    //the getObjectId func fetch the location object id from server or save a new location object for this user
                    self.par.getObjectId(classN: "Locations", uData: self.userData)
                    UserDefaults.standard.set(self.nameTextField.text!, forKey: "UserName")
                    self.navigationController?.pushViewController(UserTableViewController(parseServer: self.par), animated: true)
                }
            }
        } else {
            //This code is a temp solution to create a new user on server
            let user = PFUser()
            user.username = nameTextField.text
            user.email = nameTextField.text
            user.password = passTextField.text
            
            user.signUpInBackground { (success, error) in
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
                    self.userData.name = self.nameTextField.text!
                    //get the object ID or save new(it shouldnt exist since its a new user)
                    self.par.getObjectId(classN: "Locations", uData: self.userData)
                    self.SwitchPagePressed()
                }
            }
        }
    }
    
    @objc private func SwitchPagePressed() {
        
        if isloginPage {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.red]
        navigationItem.title = "SignUp Page"
        loginButton.setTitle("SignUp", for: .normal)
        switchPageButton.setTitle("Go to Login page", for: .normal)
        isloginPage = false
            
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
            navigationItem.title = "Login Page"
            loginButton.setTitle("Login", for: .normal)
            switchPageButton.setTitle("Go to SignUp page", for: .normal)
            isloginPage = true
        }
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        nameTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
    }
}
