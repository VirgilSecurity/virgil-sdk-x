//
//  ChatViewController.swift
//  VirgilFirebaseChat
//
//  Created by Pavel Gorb on 6/17/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import Foundation

// TODO: Implement leaving the chat.

class ChatViewController: SLKTextViewController {
    
    private var dbRef: FIRDatabaseReference! = nil
    private var dbMessagesHandle: FIRDatabaseHandle! = nil
    private var dbParticipantsHandle: FIRDatabaseHandle! = nil
    
    private var messages = [Dictionary<String, String>]()
    
    private var client = VSSClient(applicationToken: Constants.Virgil.Token)
    
    private let mutex: NSObject = NSObject()
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }

    init() {
        super.init(tableViewStyle: .Plain)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        self.title = "Secure chat"
        self.dbRef = FIRDatabase.database().reference()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            /// First of all - load all existing chat participants
            let participants = self.loadChatParticipants()
            /// If there is no current user present
            if !participants.contains(AppState.sharedInstance.identity) {
                /// Add current user as a chat participant.
                self.dbRef.child(Constants.Firebase.Participants).childByAutoId().setValue([Constants.Participant.Identity: AppState.sharedInstance.identity])
            }
            
            self.setupParticipantsHandler()
            self.setupMessagesHandler()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.clearFirebaseHandlers()
        AppState.sharedInstance.kill()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Firebase event handlers setup
    
    private func setupParticipantsHandler() {
        /// Here we also attach listener for chat participants adding event.
        self.dbParticipantsHandle = self.dbRef.child(Constants.Firebase.Participants).observeEventType(.ChildAdded, withBlock: { snapshot in
            /// Get the participant
            if let participant = snapshot.value as? Dictionary<String, String>,
                /// Get participant's identity
                identity = participant[Constants.Participant.Identity],
                /// Fetch the card
                card = self.cardForIdentity(identity) {
                /// Save (re-save) the card
                synchronized(self.mutex, closure: {
                    AppState.sharedInstance.cards[identity] = card
                })
            }
        })
    }
    
    private func setupMessagesHandler() {
        /// Here we also want to start getting messages
        self.dbMessagesHandle = self.dbRef.child(Constants.Firebase.Messages).observeEventType(.ChildAdded, withBlock: { snapshot in
            if let message = snapshot.value as? Dictionary<String, String> {
                let plainMessage = self.verifyAndDecryptSecureMessage(message)
                if plainMessage.count > 0 {
                    dispatch_async(dispatch_get_main_queue(), { 
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
                        let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top
                
                        self.tableView.beginUpdates()
                        self.messages.insert(plainMessage, atIndex: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
                        self.tableView.endUpdates()
                        
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    })
                }
            }
        })
    }
    
    private func clearFirebaseHandlers() {
        self.dbRef.child(Constants.Firebase.Messages).removeObserverWithHandle(self.dbMessagesHandle)
        self.dbMessagesHandle = nil
        self.dbRef.child(Constants.Firebase.Participants).removeObserverWithHandle(self.dbParticipantsHandle)
        self.dbParticipantsHandle = nil
    }
    
    private func loadChatParticipants() -> Array<String> {
        let task = XAsyncTask { (weakTask) in
            self.dbRef.child(Constants.Firebase.Participants).observeSingleEventOfType(.Value, withBlock: { snapshot in
                var participants = Array<String>()
                if snapshot.value != nil && !(snapshot.value is NSNull) {
                    /// For all the participants
                    for child in snapshot.children {
                        /// Participant's identity
                        if let identity = child.value[Constants.Participant.Identity] as? String,
                            /// Participant's card
                            participantCard = self.cardForIdentity(identity) {
                            /// Cache card in local dictionary
                            synchronized(self.mutex, closure: {
                                AppState.sharedInstance.cards[identity] = participantCard
                            })
                            participants.append(identity)
                        }
                    }
                }
                weakTask?.result = participants
                /// Mark task as completed.
                weakTask?.fireSignal()
            })
        }
        /// Wait until firebase returns all the participants and we finish our setup.
        task.awaitSignal()
        if let participants = task.result as? Array<String> {
            return participants
        }
        
        return Array<String>()
    }
    
    // MARK: - Action handlers
    
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(sender: AnyObject!) {
        let message = self.composeSecureMessageWithText(self.textView.text)
        if message.count > 0 {
            self.dbRef.child(Constants.Firebase.Messages).childByAutoId().setValue(message)
        }
        super.didPressRightButton(sender)
    }
    
    // MARK: - Virgil
    
    private func cardForIdentity(identity: String) -> VSSCard? {
        /// If there is card stored in local dictionary - return it.
        if let card = AppState.sharedInstance.cards[identity] {
            return card
        }
        
        /// Create async task
        let task = XAsyncTask { weakTask in
            /// Which initiates search for the card on the Virgil Service
            self.client.searchCardWithIdentityValue(identity, type: Constants.Virgil.FirebaseChatUser, unauthorized: false) { (cards, error) in
                if error != nil {
                    print("Error getting card from Virgil Service")
                    /// In case of error - mark task as fiished.
                    weakTask?.fireSignal()
                    return
                }
                
                /// Get the card from the service response if possible
                if let candidates = cards where candidates.count > 0 {
                    weakTask?.result = candidates[0]
                }
                /// And mark the task as finished.
                weakTask?.fireSignal()
            }
        }
        /// Perform the task body and wait until task is signalled resolved.
        task.awaitSignal()
        /// If there is card actually get from the Virgil Service
        if let card = task.result as? VSSCard {
            /// Synchronously save it in the local dictionary for futher use.
            synchronized(self.mutex, closure: {
                AppState.sharedInstance.cards[card.identity.value] = card
            })
            return card
        }
        
        return nil
    }
    
    private func composeSecureMessageWithText(text: String) -> Dictionary<String, String> {
        /// Create async task
        let task = XAsyncTask { (weakTask) in
            /// Convert plain text to binary data first.
            if let plainData = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                /// Initiate encryption of the plain data:
                /// Create cryptor first
                let cryptor = VSSCryptor()
                /// Add all known at the moment chat participants as the recipients:
                for (identity, card) in AppState.sharedInstance.cards {
                    do {
                        try cryptor.addKeyRecipient(card.Id, publicKey: card.publicKey.key, error: ())
                    }
                    catch let error as NSError {
                        print("Error adding '\(identity)' as a recipient for encryption: \(error.localizedDescription)")
                    }
                }
                
                /// Now encrypt the plain data:
                if let encryptedData = try? cryptor.encryptData(plainData, embedContentInfo: true, error: ()) {
                    /// plain data is encrypted now
                    /// But we are not quite done here.
                    /// Let's compose the signature over the encrypted data,
                    /// so the recipient can be sure that we are sending the message, not other user.
                    let signer = VSSSigner()
                    if let signature = try? signer.signData(encryptedData, privateKey: AppState.sharedInstance.privateKey.key, keyPassword: AppState.sharedInstance.privateKey.password, error: ()) {
                        /// Signature has been created.
                        /// Now we can pack all the things into the message structure
                        var message = Dictionary<String, String>()
                        message[Constants.Message.Identity] = AppState.sharedInstance.identity
                        message[Constants.Message.Content] = encryptedData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                        message[Constants.Message.Signature] = signature.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                        /// Return composed message ready to be sent.
                        weakTask?.result = message
                        return
                    }
                }
            }
            weakTask?.result = nil
        }
        /// Wait until encryption is done
        task.await()
        if let message = task.result as? Dictionary<String, String> {
            return message
        }
        
        return Dictionary<String, String>()
    }
    
    private func verifyAndDecryptSecureMessage(message: Dictionary<String, String>) -> Dictionary<String, String> {
        /// Create async task
        let task = XAsyncTask { (weakTask) in
            /// Get idenity of the sender
            if let sender = message[Constants.Message.Identity],
                /// Get the message content in base64
                content64 = message[Constants.Message.Content],
                /// Convert the content to the data (this data is encrypted),
                content = NSData.init(base64EncodedString: content64, options: .IgnoreUnknownCharacters),
                /// Get the sender's signature in base64
                signature64 = message[Constants.Message.Signature],
                /// Convert the signature to the binary data
                signature = NSData.init(base64EncodedString: signature64, options: .IgnoreUnknownCharacters),
                /// And finally - get the card of the current user
                card = AppState.sharedInstance.cards[AppState.sharedInstance.identity] {
                
                /// Get the card of the sender (from the local dict or from the VirgilService)
                if let senderCard = self.cardForIdentity(sender) {
                    /// Now we need to verify sender's signature, 
                    /// To be sure that message has come from this exact user
                    let verifier = VSSSigner()
                    do {
                        try verifier.verifySignature(signature, data: content, publicKey: senderCard.publicKey.key, error: ())
                    }
                    catch let error as NSError {
                        /// Error signature verification. Sender is untrusted.
                        print("Signature of sender can not be verified. Message sender is untrusted. Error: \(error.localizedDescription)")
                        /// Will not continue if sender is untrusted.
                        return
                    }
                    
                    /// In case signature verification has passed without errors
                    /// We can decrypt the message itself
                    let decryptor = VSSCryptor()
                    /// Decryption is performed using the current user's private key.
                    if let plainData = try? decryptor.decryptData(content, recipientId: card.Id, privateKey: AppState.sharedInstance.privateKey.key, keyPassword: AppState.sharedInstance.privateKey.password, error: ()),
                        /// Decode plain text from the decrypred binary data
                        text = NSString(data: plainData, encoding: NSUTF8StringEncoding) {
                        /// Compose the plain message dictionary
                        var message = Dictionary<String, String>()
                        message[Constants.Message.Identity] = sender
                        message[Constants.Message.Text] = text as String
                        
                        weakTask?.result = message
                        return
                    }
                    else {
                        let text = "<Encrypted message. Unable to read.>"
                        var message = Dictionary<String, String>()
                        message[Constants.Message.Identity] = sender
                        message[Constants.Message.Text] = text as String
                        
                        weakTask?.result = message
                        return
                    }
                    
                }
            }
            weakTask?.result = nil
        }
        /// Wait until message is verified and decrypted.
        task.await()
        
        if let message = task.result as? Dictionary<String, String> {
            return message
        }
        
        return Dictionary<String, String>()
    }

    // MARK: - UITableViewDelegate/DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return self.messages.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            return self.messageCellForRowAtIndexPath(indexPath)
        }
        else {
            return UITableViewCell(style: .Default, reuseIdentifier: Constants.UI.ChatMessageCell)
        }
    }
    
    func messageCellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(Constants.UI.ChatMessageCell) ?? UITableViewCell(style: .Subtitle, reuseIdentifier: Constants.UI.ChatMessageCell)

        let message = self.messages[indexPath.row]
        cell.textLabel?.text = message[Constants.Message.Text]
        cell.detailTextLabel?.text = message[Constants.Message.Identity]
        cell.transform = self.tableView.transform
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == self.tableView {
            let message = self.messages[indexPath.row]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            paragraphStyle.alignment = .Left
            
            let pointSize = CGFloat(14.0)
            
            let attributes = [
                NSFontAttributeName : UIFont.systemFontOfSize(pointSize),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
            
            var width = CGRectGetWidth(tableView.frame)
            width -= 25.0
            
            let titleBounds = (message[Constants.Message.Identity]! as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            let bodyBounds = (message[Constants.Message.Text]! as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            
            if message[Constants.Message.Text]!.characters.count == 0 {
                return 0
            }
            
            var height = CGRectGetHeight(titleBounds)
            height += CGRectGetHeight(bodyBounds)
            height += 40
            
            if height < 40.0 {
                height = 40.0
            }
            
            return height
        }
        else {
            return 40.0
        }
    }
}