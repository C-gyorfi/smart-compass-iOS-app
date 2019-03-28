//
//  ChatTableViewController.swift
//  Compass
//
//  Created by Csabi on 11/12/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import UIKit
import Parse

class ChatTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    fileprivate let cellId = "id"
    let parse = PServer()
    var messagesFromServer = [ChatMessage]()
    let textField = UITextField()
    let sendButton = UIButton()
    let tableView = UITableView()
    @IBOutlet weak var textFieldBottomConstaint: NSLayoutConstraint!
    
    private func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.cyan]
        navigationItem.title = "Messsages"
        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.darkGray
        
        sendButton.setTitleColor(UIColor.blue, for: .normal)
        sendButton.setTitle("Send", for: .normal)
        
        textField.backgroundColor = UIColor.gray
        textField.textColor = UIColor.white
        textField.layer.cornerRadius = 14
        
        let textFieldStack = UIStackView(arrangedSubviews: [textField, sendButton])
        textFieldStack.axis = .horizontal
        textFieldStack.spacing = 0
        
        self.view.addSubview(textFieldStack)
        textFieldStack.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([textField.widthAnchor.constraint(equalToConstant: 120),
                                    textFieldStack.heightAnchor.constraint(equalToConstant: 50),
                                     textFieldStack.widthAnchor.constraint(equalToConstant: 180),
                                     textFieldStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     textFieldStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: textFieldStack.topAnchor),
                                     tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                                     tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)])
        }
    
    private func setUpHandlers() {
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc private func sendMessage() {
        
        guard let currentUser = PFUser.current()?.username else {
            return
        }
        
        guard let message = textField.text, message.count > 0 else {
            return
        }
        
        guard let targerUserName = UserDefaults.standard.string(forKey: "targetUserName") else {
            return
        }
        
        parse.saveChatMessage(user1: currentUser, user2: targerUserName, chatMessage: [currentUser, message,"no date"]) { (success, error) in
            if success {
                self.fetchChatMessages()
                self.textField.text = ""
            }
        }
    }
    
    private func fetchChatMessages() {
        
        guard let currentUser = PFUser.current()?.username else {
            return
        }
        
        guard let targerUserName = UserDefaults.standard.string(forKey: "targetUserName") else {
            return
        }
        parse.fetchChat(user1: currentUser, user2:targerUserName) { (chatMessages, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let chatMessages = chatMessages {
                self.messagesFromServer = chatMessages
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        setUpHandlers()
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    @objc func keyboardWillShow(notification: Notification) {
        view.frame.origin.y = -214
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        view.frame.origin.y = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
       fetchChatMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesFromServer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatMessage = messagesFromServer[indexPath.row]
        return cell
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("recognised")
        textField.resignFirstResponder()
    }
    
    public func releaseKeyboard() {
        textField.resignFirstResponder()
    }
}

class ChatMessageCell: UITableViewCell {
    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    var leadingConstraint = NSLayoutConstraint()
    var trailingConstraint = NSLayoutConstraint()
    
    var chatMessage: ChatMessage! {
        didSet {
            var isIncoming: Bool
            if let currentUser = PFUser.current()?.username {
                isIncoming = chatMessage.sender != currentUser
            } else {
                return
            }
            bubbleBackgroundView.backgroundColor = isIncoming ? UIColor.green : UIColor.gray
            messageLabel.textColor = isIncoming ? UIColor.black : UIColor.white
            messageLabel.text = chatMessage.text
            
            if isIncoming{
                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
            } else {
                leadingConstraint.isActive = false
                trailingConstraint.isActive =  true
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        bubbleBackgroundView.layer.cornerRadius = 14
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        messageLabel.textColor = UIColor.white
        messageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        messageLabel.numberOfLines = 0
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
                                     messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 230),
                                     messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
                                     bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
                                     bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
                                     bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
                                     bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16)])
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        leadingConstraint.isActive = false
        
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        trailingConstraint.isActive = false
    }
}
