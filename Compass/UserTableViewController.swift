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
    var curretUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
        navigationItem.title = "Users"
        
        tableView.register(newCell.self, forCellReuseIdentifier: cellID)
        
        guard let userName = UserDefaults.standard.string(forKey: "UserName") else {
            print("ERROR current user doesnt exist")
            self.navigationController?.popViewController(animated: true)
            return
        }
        curretUserName = userName
        
        let query = PFUser.query()
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error ?? "error while fetching user names")
            } else if let users = objects {
                self.userNames.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        if user.username != self.curretUserName {
                            self.userNames.append(user.username!)}
                    }
                }
            }
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
