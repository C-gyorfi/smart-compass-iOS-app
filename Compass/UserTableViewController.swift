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

    var userList = [""]
    var userData = UserData()
    let par: PServer
    
    init(parseServer: PServer) {
        par = parseServer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
        navigationItem.title = "Users"
        
        //Help: custom icon positioning is not working, who to fix this?
        var accountIcon = UIImage(named: "noavatar.png")
        accountIcon = UIImage(cgImage: (accountIcon?.cgImage!)!, scale: 0.1, orientation: .up)

        //To create a custom bar button item from a png image with template color
        let accSettingsButton = UIButton()
        accSettingsButton.addTarget(self, action: #selector(barbuttontapped), for: .touchUpInside)
        accSettingsButton.setImage(UIImage(named: "accountimg.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        //accSettingsButton.tintColor = UIColor.blue
        accSettingsButton.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        accSettingsButton.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: accSettingsButton)
        

        let logoutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logout))
        logoutButton.tintColor = UIColor.red
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = logoutButton
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        guard let userName = PFUser.current()?.username else {
            print("ERROR current user doesnt exist")
            self.navigationController?.popViewController(animated: true)
            return
        }
        userData.name = userName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchUserList()
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
        return userList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = userList[indexPath.row]
        cell.backgroundColor = UIColor.darkGray;
        cell.textLabel?.textColor = UIColor.cyan
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if let userName = cell?.textLabel?.text {
        UserDefaults.standard.set(userName, forKey: "targetUserName")
        self.navigationController?.pushViewController(UserProfileViewController(), animated: true)
        }
    }
    
    fileprivate func fetchUserList() {
        par.fetchUserList { (list, error) in
            guard error == nil else {
                print (error ?? "error while fetching user names")
                return
            }
            if let listOfUsers = list {
                self.userList = listOfUsers
                self.tableView.reloadData()
            }
        }
    }
}
