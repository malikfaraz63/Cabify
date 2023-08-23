//
//  RequestMessagesController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 04/08/2023.
//

import UIKit
import MessageKit


class RequestMessagesController: MessagesViewController {
    private var previousRequestId: String?
    var requestId: String?
    var riderName: String?
    
    var requestClient: RequestClient?
    
    private var messages: [MessageType] = []
    private var driverMessages: [MessageType] = []
    private var riderMessages: [MessageType] = []
    
    private let driver = Sender(senderId: "driver", displayName: "You")
    private var rider = Sender(senderId: "rider", displayName: "Rider")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.contentInset = UIEdgeInsets(top: 100, left: 10, bottom: 20, right: 10)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        messageInputBar.sendButton.onTouchUpInside { _ in self.sendMessage() }
        // Do any additional setup after loading the view.
        viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let riderName = riderName {
            rider.displayName = riderName
        }
        
        if let requestId = requestId {
            if let previousRequestId = previousRequestId {
                if previousRequestId == requestId {
                } else {
                    self.previousRequestId = requestId
                    setMessagesListeners()
                }
            } else {
                self.previousRequestId = requestId
                setMessagesListeners()
            }
        } else {
            previousRequestId = nil
            messages = []
            messagesCollectionView.reloadData()
        }
    }
    
    // MARK: Message Handling
    
    
    private func sendMessage() {
        print("--sendMessage--")
        guard let requestId = requestId else { return }
        print("  found requestId")
        guard let requestClient = requestClient else { return }
        print("  found requestClient")
        guard let message = messageInputBar.inputTextView.text else { return }
        print("  found message")
        if message.count == 0 {
            return
        }
        
        let requestMessage = RequestMessage(message: message, read: false, sent: Date())
        
        requestClient.sendMessage(forRequestId: requestId, message: requestMessage)
        requestClient.markRiderMessagesReadForRequestId(requestId)
        requestClient.incrementDriverUnreadForRequestId(requestId)
        messageInputBar.inputTextView.text = ""
    }
    
    private func setMessagesListeners() {
        guard let requestId = requestId else { return }
        guard let requestClient = requestClient else { return }
        
        requestClient.setRequestMessagesListener(forRequestId: requestId, messageSource: .driverMessages) { driverMessages in
            self.messagesChangedCompletion(withMessages: driverMessages, source: .driverMessages)
        }
        
        requestClient.setRequestMessagesListener(forRequestId: requestId, messageSource: .riderMessages) { driverMessages in
            self.messagesChangedCompletion(withMessages: driverMessages, source: .riderMessages)
        }
    }
    
    private func messagesChangedCompletion(withMessages messages: [RequestMessage], source: RequestMessageSource) {
        if source == .driverMessages {
            driverMessages.removeAll()
            for message in messages {
                driverMessages.append(MessageViewModel(from: message, sender: self.driver))
            }
        } else {
            riderMessages.removeAll()
            for message in messages {
                riderMessages.append(MessageViewModel(from: message, sender: self.rider))
            }
        }
        
        self.messages.removeAll()
        self.messages.append(contentsOf: self.driverMessages)
        self.messages.append(contentsOf: self.riderMessages)
        
        self.messages.sort { $0.sentDate < $1.sentDate }
        messagesCollectionView.reloadData()
        
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
    }
}

// MARK: Data Source


extension RequestMessagesController: MessagesDataSource {
    internal var currentSender: MessageKit.SenderType {
        return driver
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

// MARK: Delegate


extension RequestMessagesController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}
