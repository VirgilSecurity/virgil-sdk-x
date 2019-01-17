//
// Copyright (C) 2015-2019 Virgil Security Inc.
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

/// Class adds virgil-agent header to collect metrics in the Cloud
public final class VirgilAgentAdapter: HttpRequestAdapter {
    private let key = "virgil-agent"
    private let product: String
    private let family: String = "x"
    private var platform: String { return VersionUtils.getPlatform() }
    private let version: String

    /// Init
    ///
    /// - Parameters:
    ///   - product: product name
    ///   - version: Semantic version
    public init(product: String, version: String) {
        self.product = product
        self.version = version
    }

    /// Adds virgil-agent header
    ///
    /// - Parameter request: request to modify
    /// - Returns: same request with virgil-agent header
    /// - Throws: No throw
    public func adapt(_ request: Request) throws -> Request {
        var headers = request.headers ?? [:]

        let value = "\(self.product);\(self.family);\(self.platform);\(self.version)"

        headers.merge([self.key: value]) { currentVal, _ in currentVal }

        request.headers = headers

        return request
    }
}
