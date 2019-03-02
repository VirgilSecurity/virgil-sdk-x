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

/// Class for handling retries for network requests
open class RequestRetry {
    /// Config for retries
    public struct Config {
        /// Max number of retries
        public var maxRetryCount: Int
        /// Max interval for retry
        public var cap: TimeInterval
        /// Minimum interval for retry (before jitter)
        public var minDelay: TimeInterval
        /// Base value for retry
        public var base: TimeInterval
        /// Exp base for retry
        public var exp: TimeInterval

        /// Init
        ///
        /// - Parameters:
        ///   - maxRetryCount: Max number of retries
        ///   - cap: Max interval for retry
        ///   - minDelay: Minimum interval for retry (before jitter)
        ///   - base: Base value for retry
        ///   - exp: Exp base for retry
        public init(maxRetryCount: Int = 3,
                    cap: TimeInterval = 10,
                    minDelay: TimeInterval = 0,
                    base: TimeInterval = 1,
                    exp: TimeInterval = 2) {
            self.maxRetryCount = maxRetryCount
            self.cap = cap
            self.minDelay = minDelay
            self.base = base
            self.exp = exp
        }
    }

    /// Retry choise
    ///
    /// - noRetry: should not retry
    /// - retryService: retry due to service error
    /// - retryAuth: retry due to auth error (should try with new Access Token)
    public enum Choice {
        case noRetry
        case retryService(delay: TimeInterval)
        case retryAuth
    }

    /// Number of performed retries
    open private(set) var retryCount: Int = 0

    /// Retry config
    public let config: Config

    /// Default init
    public convenience init() {
        self.init(config: Config())
    }

    /// Init
    ///
    /// - Parameter config: Retry config
    public init(config: Config) {
        self.config = config
    }

    /// Decide on retry
    ///
    /// - Parameters:
    ///   - request: Request to retry
    ///   - response: Response receiver from service
    /// - Returns: Retry choise
    open func retryChoice(for request: ServiceRequest, with response: Response) -> Choice {
        if 200..<400 ~= response.statusCode {
            return .noRetry
        }

        if 500..<600 ~= response.statusCode {
            do {
                let delay = try self.nextRetryDelay()

                return .retryService(delay: delay)
            }
            catch {
                return .noRetry
            }
        }

        if 400..<500 ~= response.statusCode {
            if response.statusCode == 401 {
                if let body = response.body,
                    let rawServiceError = try? JSONDecoder().decode(RawServiceError.self, from: body),
                    rawServiceError.code == 20_304 {

                    return .retryAuth
                }

                return .noRetry
            }
        }

        return .noRetry
    }

    /// Retry Error
    ///
    /// - retryCountExceeded: retry count is maximum
    public enum RetryError: Error {
        case retryCountExceeded
    }

    /// Next delat for retry
    ///
    /// - Returns: max(minDelay, rand(0..<min(cap, base * exp ^ retryCount)))
    /// - Throws: RetryError.retryCountExceeded if retry count is maximum
    open func nextRetryDelay() throws -> TimeInterval {
        guard self.retryCount < self.config.maxRetryCount else {
            throw RetryError.retryCountExceeded
        }

        let baseDelay = min(self.config.cap, self.config.base * pow(self.config.exp, TimeInterval(self.retryCount)))
        let jitterDelay = TimeInterval.random(in: 0..<baseDelay)
        let delay = max(self.config.minDelay, jitterDelay)

        self.retryCount += 1

        return delay
    }
}
