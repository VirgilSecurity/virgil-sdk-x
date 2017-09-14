//
//  ServiceConnection.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSServiceConnection) public class ServiceConnection: NSObject, HTTPConnection {
    private let queue: OperationQueue
    private let session: URLSession
    
    public override init() {
        self.queue = OperationQueue()
        self.queue.maxConcurrentOperationCount = 10
        
        let config = URLSessionConfiguration.ephemeral
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: self.queue)
        
        super.init()
    }
    
    public func send(_ request: HTTPRequest) throws -> HTTPResponse {
        let nativeRequest = request.getNativeRequest()
        
        guard let url = nativeRequest.url else {
            // FIXME
            throw NSError()
        }
        
        Log.debug("\(request.self): request method: \(nativeRequest.httpMethod ?? "")")
        Log.debug("\(request.self): request url: \(url.absoluteString)")
        if let data = nativeRequest.httpBody, data.count > 0, let str = String(data: data, encoding: .utf8) {
            Log.debug("\(request.self): request body: \(str)")
        }
        Log.debug("\(request.self): request headers: \(nativeRequest.allHTTPHeaderFields ?? [:])")
        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookies {
                Log.debug("*******COOKIE: \(cookie.name): \(cookie.value)")
            }
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var dataT: Data?
        var responseT: URLResponse?
        var errorT: Error?
        self.session.dataTask(with: nativeRequest) { dataR, responseR, errorR in
            dataT = dataR
            responseT = responseR
            errorT = errorR
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = errorT {
            throw error
        }
        
        guard let response = responseT as? HTTPURLResponse else {
            // FIXME
            throw NSError()
        }
        
        Log.debug("\(request.self): response URL: \(response.url?.absoluteString ?? "")")
        Log.debug("\(request.self): response HTTP status code: \(response.statusCode)")
        Log.debug("\(request.self): response headers: \(response.allHeaderFields)")
        
        
        if let data = dataT, data.count > 0, let str = String(data: data, encoding: .utf8) {
            Log.debug("\(request.self): response body: \(str)")
        }
        
        return ServiceResponse(statusCode: response.statusCode, response: response, body: dataT)
    }
    
    deinit {
        self.session.invalidateAndCancel()
        self.queue.cancelAllOperations()
    }
}

@objc(VSSServiceResponse) public class ServiceResponse: NSObject, HTTPResponse {
    public let statusCode: Int
    public let response: HTTPURLResponse
    public let body: Data?

    public init(statusCode: Int, response: HTTPURLResponse, body: Data?) {
        self.statusCode = statusCode
        self.response = response
        self.body = body
    }
}

@objc(VSSServiceRequest) public class ServiceRequest: NSObject, HTTPRequest {
    private let url: URL
    private let method: Method
    private let apiToken: String?
    
    public static let DefaultTimeout: TimeInterval = 45
    public static let AccessTokenHeader = "Authorization"
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
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
