//
// Copyright (C) 2015-2020 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

/// Declares error types and codes
///
/// - noUrlInRequest: Provided URLRequest doesn't have url
/// - wrongResponseType: Response is not of HTTPURLResponse type
@objc(VSSServiceConnectionError) public enum ServiceConnectionError: Int, LocalizedError {
    case noUrlInRequest = 1
    case wrongResponseType = 2

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .noUrlInRequest:
            return "Provided URLRequest doesn't have url"
        case .wrongResponseType:
            return "Response is not of HTTPURLResponse type"
        }
    }
}

/// Simple HttpConnection implementation
open class HttpConnection: HttpConnectionProtocol {
    /// Default number of maximum concurrent operations
    public static let defaulMaxConcurrentOperationCount = 10
    /// Url session used to create network tasks
    private let session: URLSession

    private let adapters: [HttpRequestAdapter]

    /// Init
    ///
    /// - Parameters:
    ///   - adapters: request adapters
    public init(adapters: [HttpRequestAdapter] = []) {
        let config = URLSessionConfiguration.ephemeral
        self.session = URLSession(configuration: config)

        self.adapters = adapters
    }

    /// Sends Request and returns Response over http
    ///
    /// - Parameter request: Request to send
    /// - Returns: Obtained response
    /// - Throws: ServiceConnectionError.noUrlInRequest if provided URLRequest doesn't have url
    ///           ServiceConnectionError.wrongResponseType if response is not of HTTPURLResponse type
    public func send(_ request: Request) throws -> GenericOperation<Response> {
        let nativeRequest = try self.adapters
            .reduce(request) { _, adapter -> Request in
                try adapter.adapt(request)
            }
            .getNativeRequest()

        guard let url = nativeRequest.url else {
            throw ServiceConnectionError.noUrlInRequest
        }

        let className = String(describing: type(of: self))

        Log.debug("\(className): request method: \(nativeRequest.httpMethod ?? "")")
        Log.debug("\(className): request url: \(url.absoluteString)")
        if let data = nativeRequest.httpBody, !data.isEmpty, let str = String(data: data, encoding: .utf8) {
            Log.debug("\(className): request body: \(str)")
        }
        Log.debug("\(className): request headers: \(nativeRequest.allHTTPHeaderFields ?? [:])")
        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookies {
                Log.debug("*******COOKIE: \(cookie.name): \(cookie.value)")
            }
        }

        return NetworkOperation(request: nativeRequest, session: self.session)
    }

    deinit {
        self.session.invalidateAndCancel()
    }
}
