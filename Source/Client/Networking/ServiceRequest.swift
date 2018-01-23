//
//  ServiceRequest.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/19/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSServiceRequest) public class ServiceRequest: NSObject, HTTPRequest {
    let url: URL
    let method: Method
    let apiToken: String?
    let body: Data?
    
    @objc public static let DefaultTimeout: TimeInterval = 45
    @objc public static let AccessTokenHeader = "Authorization"
    
    public enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    public init(url: URL, method: Method, apiToken: String?, bodyJson: Any? = nil) throws {
        self.url = url
        self.method = method
        self.apiToken = apiToken
        
        if let bodyJson = bodyJson {
            self.body = try JSONSerialization.data(withJSONObject: bodyJson, options: [])
        }
        else {
            self.body = nil
        }
        
        super.init()
    }
    
    @objc public init(urlRequest: URLRequest) throws {
        guard let url = urlRequest.url,
            let methodStr = urlRequest.httpMethod,
            let method = Method(rawValue: methodStr) else {
                throw NSError()
        }
        
        self.url = url
        self.method = method
        self.apiToken = urlRequest.value(forHTTPHeaderField: ServiceRequest.AccessTokenHeader)
        self.body = urlRequest.httpBody
    }
    
    public func getNativeRequest() -> URLRequest {
        var request = URLRequest(url: self.url)
        
        request.timeoutInterval = ServiceRequest.DefaultTimeout
        request.httpMethod = self.method.rawValue
        request.setValue("Virgil \(String(describing: self.apiToken))", forHTTPHeaderField: ServiceRequest.AccessTokenHeader)
        request.httpBody = self.body
        
        return request
    }
}

extension NSURLRequest: HTTPRequest {
    public func getNativeRequest() -> URLRequest {
        return self as URLRequest
    }
}
