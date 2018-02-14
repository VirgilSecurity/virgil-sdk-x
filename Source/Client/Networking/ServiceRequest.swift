//
//  ServiceRequest.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

open class ServiceRequest: Request {
    @objc(VSSServiceRequestError) public enum ServiceRequestError: Int, Error {
        case invalidGetRequestParameters = 1
        case urlComponentsConvertingFailed = 2
        case getQueryWithDecodableIsNotSupported = 3
    }

    public static let accessTokenHeader = "Authorization"
    public static let accessTokenPrefix = "Virgil"

    public init<T: Encodable>(url: URL, method: Method, accessToken: String, params: T? = nil) throws {
        let bodyData: Data?
        let newUrl: URL

        switch method {
        case .get:
            guard params == nil else {
                throw ServiceRequestError.getQueryWithDecodableIsNotSupported
            }

            bodyData = nil
            newUrl = url

        case .post, .put, .delete:
            if let bodyEncodable = params {
                bodyData = try JSONEncoder().encode(bodyEncodable)
            }
            else {
                bodyData = nil
            }

            newUrl = url
        }

        let headers = [ServiceRequest.accessTokenHeader: "\(ServiceRequest.accessTokenPrefix) \(accessToken)"]
        super.init(url: newUrl, method: method, headers: headers, body: bodyData)
    }

    public init(url: URL, method: Method, accessToken: String, params: Any? = nil) throws {
        let bodyData: Data?
        let newUrl: URL

        switch method {
        case .get:
            if let params = params {
                guard let params = params as? [String: String] else {
                    throw ServiceRequestError.invalidGetRequestParameters
                }

                var components = URLComponents(string: url.absoluteString)

                components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }

                guard let url = components?.url else {
                    throw ServiceRequestError.urlComponentsConvertingFailed
                }
                newUrl = url
            }
            else {
                newUrl = url
            }
            bodyData = nil

        case .post, .put, .delete:
            if let bodyJson = params {
                bodyData = try JSONSerialization.data(withJSONObject: bodyJson, options: [])
            }
            else {
                bodyData = nil
            }

            newUrl = url
        }

        let headers = [ServiceRequest.accessTokenHeader: "\(ServiceRequest.accessTokenPrefix) \(accessToken)"]
        super.init(url: newUrl, method: method, headers: headers, body: bodyData)
    }
}
