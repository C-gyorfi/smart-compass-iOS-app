//
//  ChatTableViewController.swift
//  Compass
//
//  Created by Csabi on 11/12/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
}

class ChatTableViewController: UITableViewController {

    fileprivate let cellId = "id"
    let parse = PServer()
    
    let testChatArray = [["Sam","This is the first message","10/10/2018"], ["Tom","This is the second message","09/10/2018"], ["Sam","This is the thirst message","11/10/2018"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
        navigationItem.title = "Messsages"
        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.darkGray
        
        //parse.saveChatMessage(user1: "Sam", user2: "Tom", chatMessage: ["Sam", "This is a message from Sam to Tom", "11/10/2038"])
        
        parse.fetchChat(user1: "Sam", user2: "Tom") { (chatMessages, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let chatMessages = chatMessages as? [ChatMessage] else {
                return
            }
            
            for message in chatMessages {
                print(message)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
}
