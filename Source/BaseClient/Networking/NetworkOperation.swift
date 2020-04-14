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

/// Network Operation
open class NetworkOperation: GenericOperation<Response> {
    /// Task type
    public typealias Task = (NetworkOperation, @escaping (Response?, Error?) -> Void) -> Void

    /// Task to execute
    public let request: URLRequest

    /// Url Sesssion
    public let session: URLSession

    /// Task
    public private(set) var task: URLSessionTask?

    /// Initializer
    ///
    /// - Parameter task: task to execute
    public init(request: URLRequest, session: URLSession) {
        self.request = request
        self.session = session

        super.init()
    }

    /// Main function
    override open func main() {
        let task = self.session.dataTask(with: self.request) { [unowned self] data, response, error in
            defer {
                self.finish()
            }

            if let error = error {
                self.result = .failure(error)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                self.result = .failure(ServiceConnectionError.wrongResponseType)
                return
            }

            Log.debug("NetworkOperation: response URL: \(response.url?.absoluteString ?? "")")
            Log.debug("NetworkOperation: response HTTP status code: \(response.statusCode)")
            Log.debug("NetworkOperation: response headers: \(response.allHeaderFields as AnyObject)")

            if let body = data, let str = String(data: body, encoding: .utf8) {
                Log.debug("NetworkOperation: response body: \(str)")
            }

            let result = Response(statusCode: response.statusCode, response: response, body: data)

            self.result = .success(result)
        }

        self.task = task
        task.resume()
    }

    /// Cancel
    override open func cancel() {
        self.task?.cancel()

        super.cancel()
    }
}
