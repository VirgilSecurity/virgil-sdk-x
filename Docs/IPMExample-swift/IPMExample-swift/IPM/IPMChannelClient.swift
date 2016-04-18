//
//  IPMChannelClient.swift
//  IPMExample-swift
//
//  Created by Pavel Gorb on 4/18/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import Foundation

class IPMChannelClient: NSObject {
    
    private(set) var userId: String
    private(set) var channel: IPMDataSource! = nil
    
    private var session: NSURLSession
    
    init(userId: String) {
        self.userId = userId
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
        super.init()
    }
    
    func joinChannel(name: String, listener: IPMDataSourceListener) -> XAsyncActionResult {
        return { () -> AnyObject? in
            let urlString = "\(kBaseURL)/channels/\(name)/join"
            if let url = NSURL(string: urlString) {
                let dto = [kSenderIdentifier: self.userId]
                let httpBody = try? NSJSONSerialization.dataWithJSONObject(dto, options: NSJSONWritingOptions(rawValue: 0))
                
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = httpBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let semaphore = dispatch_semaphore_create(0)
                var actionError: NSError? = nil
                let task = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    if error != nil {
                        actionError = error
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    let r = response as! NSHTTPURLResponse
                    if r.statusCode >= 400 {
                        let httpError = NSError(domain: "HTTPError", code: r.statusCode, userInfo: [ NSLocalizedDescriptionKey: NSLocalizedString(NSHTTPURLResponse.localizedStringForStatusCode(r.statusCode), comment: "No comments") ])
                        actionError = httpError
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    if data == nil {
                        actionError = NSError(domain: "JoinChannelError", code: -5767, userInfo: nil)
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    let dto = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    if dto == nil {
                        actionError = NSError(domain: "JoinChannelError", code: -4534, userInfo: nil)
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    if let token = dto![kIdentityToken] as? String {
                        self.channel = IPMChannel(name: name, token: token)
                        self.channel.startListeningWithHandler(listener)
                        actionError = nil
                        dispatch_semaphore_signal(semaphore)
                        return
                    }

                    actionError = NSError(domain: "JoinChannelError", code: -3436, userInfo: nil)
                    dispatch_semaphore_signal(semaphore)
                })
                task.resume()
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                return actionError
            }
            return NSError(domain: "JoinChannelError", code: -4545, userInfo: nil)
        }
    }
    
    func leaveChannel() {
        self.channel.stopListening()
        self.channel = nil
    }
}