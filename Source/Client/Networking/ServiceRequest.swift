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
    
    public static let DefaultTimeout: TimeInterval = 45
    public static let AccessTokenHeader = "Authorization"
    
    public enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    public init(url: URL, method: Method, apiToken: String?) {
        self.url = url
        self.method = method
        self.apiToken = apiToken
        
        super.init()
    }
    
    public init?(urlRequest: URLRequest) {
        guard let url = urlRequest.url,
            let methodStr = urlRequest.httpMethod,
            let method = Method(rawValue: methodStr) else {
                return nil
        }
        
        self.url = url
        self.method = method
        self.apiToken = urlRequest.value(forHTTPHeaderField: ServiceRequest.AccessTokenHeader)
    }
    
    public func getNativeRequest() -> URLRequest {
        var request = URLRequest(url: self.url)
        
        request.timeoutInterval = ServiceRequest.DefaultTimeout
        request.httpMethod = self.method.rawValue
        request.setValue(self.apiToken, forHTTPHeaderField: ServiceRequest.AccessTokenHeader)
        
        return request
    }
}

extension NSURLRequest: HTTPRequest {
    public func getNativeRequest() -> URLRequest {
        return self as URLRequest
    }
}
