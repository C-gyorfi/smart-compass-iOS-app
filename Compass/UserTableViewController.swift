//
//  UserTableViewController.swift
//  Compass
//
//  Created by Csabi on 12/10/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {

    let cellID = "CellID"
    var userNames = [""]
    var userData = UserData()
    let par = PServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Help: custom icon positioning is not working, who to fix this?
//        let accountIcon = UIImage(named: "accountimg.png")
//        let accSettingsButton = UIBarButtonItem(image: accountIcon?.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1), style: .plain, target: self, action: #selector(barbuttontapped))
//        self.navigationItem.rightBarButtonItem?.backButtonBackgroundVerticalPositionAdjustment(for: UIBarMetrics(rawValue: 5)!)

        let logoutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logout))
        logoutButton.tintColor = UIColor.red
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = logoutButton
        
        let accSettingsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(barbuttontapped))
        self.navigationItem.rightBarButtonItem  = accSettingsButton
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
        navigationItem.title = "Users"
        
        tableView.register(newCell.self, forCellReuseIdentifier: cellID)
        
        guard let userName = UserDefaults.standard.string(forKey: "UserName") else {
            print("ERROR current user doesnt exist")
            self.navigationController?.popViewController(animated: true)
            return
        }
        userData.name = userName
        
        let query = PFUser.query()
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error ?? "error while fetching user names")
            } else if let users = objects {
                self.userNames.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        if user.username != self.userData.name {
                            self.userNames.append(user.username!)}
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    @objc func barbuttontapped() {
        self.navigationController?.pushViewController(AccountSettingsViewController(), animated: true)
    }
    
    @objc func logout() {
        UserDefaults.standard.removeObject(forKey: "locationObjectId")
        UserDefaults.standard.removeObject(forKey: "userName")
        PFUser.logOut()
        print("logging out")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = userNames[indexPath.row]
        cell.backgroundColor = UIColor.darkGray;
        cell.textLabel?.textColor = UIColor.cyan

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if let userName = cell?.textLabel?.text {
        UserDefaults.standard.set(userName, forKey: "targetUserName")
        self.navigationController?.pushViewController(CompassViewController(), animated: true)
        }
    }
    

    class newCell: UITableViewCell {
        
        let taskLabel: UILabel = {

            let label = UILabel()
           // label.text = "Test Name"
            label.textColor = UIColor.cyan
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = UIColor.darkGray
            return label

        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
           // setupViews()
        }
        
        func setupViews() {

            addSubview(taskLabel)

            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-100 -[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : taskLabel] ))

            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : taskLabel] ))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
