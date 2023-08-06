//
//  RequestMessage.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 04/08/2023.
//

import Foundation
import MessageKit

class MessageViewModel: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
    
    init(from message: RequestMessage, sender: SenderType) {
        self.sender = sender
        self.messageId = message.sent.description
        self.sentDate = message.sent
        self.kind = .text(message.message)
    }
}
