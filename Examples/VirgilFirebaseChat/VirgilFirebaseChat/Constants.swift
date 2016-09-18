//
//  Constants.swift
//  VirgilFirebaseChat
//
//  Created by Pavel Gorb on 6/17/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import Foundation

struct Constants {

    struct Virgil {
        static let Token = "eyJpZCI6IjM2YTg0MGVhLWIxZjctNDIyZC1hZmZjLWVlNjc1NmFiODExMiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiJhODZiNDYzMy1lMjE1LTQ5YzMtYTMyMS1jOTFlMGQ2YjU1MTQiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MFcwDQYJYIZIAWUDBAICBQAERjBEAiAzvUdK2RNACiekg7aP+jP61dL6iAJ8JN/8XNedzDVeDQIgZRecWIBzgJffXm1kG979Qbi7lJSGvJ57ttmscZZCoKM="
        static let PrivateKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIHyMF0GCSqGSIb3DQEFDTBQMC8GCSqGSIb3DQEFDDAiBBDcK6dSKcc08X646keF\nczFXAgIeqDAKBggqhkiG9w0CCjAdBglghkgBZQMEASoEECh0Zjey/XRXW/ZEMINA\naO8EgZDaifjJokf6s/dWqpTCGGahQzp6ehxExugB+EjYUTBHyd5LxC/oExV8gr1H\nxGtpACS6o9wV0e27+LxmwC68cX4pFUIc43eaJEfwj7LclMJ+YgpLXcmojEUi+OgE\nt5ZiLLQGGcDzvDy6Jb7V/KkpFJY/q4mHRXe/hFQoWVwhetnpIhMZ1zVcKH7sSpRh\ng+LRt8Q=\n-----END ENCRYPTED PRIVATE KEY-----\n"
        static let PrivateKeyPassword = "1231"
        static let FirebaseChatUser = "FirebaseChatUser"
        static let PrivateKeyStorage = "FirebaseChatPrivateKeyStorage"
    }
    
    struct Message {
        static let Identity = "identity"
        static let Content = "content"
        static let Signature = "signature"
        static let Text = "text" 
    }
    
    struct Participant {
        static let Identity = "identity"
    }
    
    struct Firebase {
        static let Messages = "messages"
        static let Participants = "participants"
    }
    
    struct UI {
        static let ChatMessageCell = "ChatMessageCell"
    }
}