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

/// Class for handling retries for network requests
open class ExpBackoffRetry: RetryProtocol {
    /// Config for retries
    public struct Config {
        /// Max number of retries
        public var maxRetryCount: UInt
        /// Max interval for retry
        public var cap: TimeInterval
        /// Minimum interval for retry (before jitter)
        public var minDelay: TimeInterval
        /// Base value for retry
        public var base: TimeInterval
        /// Exp base for retry
        public var exp: UInt

        /// Init
        ///
        /// - Parameters:
        ///   - maxRetryCount: Max number of retries
        ///   - cap: Max interval for retry
        ///   - minDelay: Minimum interval for retry (before jitter)
        ///   - base: Base value for retry
        ///   - exp: Exp base for retry
        public init(maxRetryCount: UInt = 3,
                    cap: TimeInterval = 10,
                    minDelay: TimeInterval = 0.01,
                    base: TimeInterval = 0.2,
                    exp: UInt = 2) {
            self.maxRetryCount = maxRetryCount
            self.cap = cap
            self.minDelay = minDelay
            self.base = base
            self.exp = exp
        }
    }

    /// Number of performed retries
    open private(set) var retryCount: UInt = 0

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

    /// Decire on retry in case of error
    ///
    /// - Parameters:
    ///   - request: Request to retry
    ///   - error: Response receiver from service
    /// - Returns: Retry choice
    public func retryChoice(for request: ServiceRequest, with error: Error) -> RetryChoice {
        let nsError = error as NSError

        guard nsError.domain == NSURLErrorDomain else {
            return .noRetry
        }

        let errorCode = nsError.code

        switch errorCode {
        case NSURLErrorTimedOut,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorSecureConnectionFailed:
            return .retryConnection

        default:
            return .noRetry
        }
    }

    /// Decide on retry in case of success
    ///
    /// - Parameters:
    ///   - request: Request to retry
    ///   - response: Response receiver from service
    /// - Returns: Retry choice
    open func retryChoice(for request: ServiceRequest,
                          with response: Response) -> RetryChoice {
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
    public enum ExpBackoffRetryError: Error {
        case retryCountExceeded
    }

    /// Next delauy for retry
    ///
    /// - Returns: max(minDelay, rand(0..<min(cap, base * exp ^ retryCount)))
    /// - Throws: RetryError.retryCountExceeded if retry count is maximum
    open func nextRetryDelay() throws -> TimeInterval {
        guard self.retryCount < self.config.maxRetryCount else {
            throw ExpBackoffRetryError.retryCountExceeded
        }

        let uintPow = { (base: UInt, pow: UInt) -> UInt in
            guard pow != 0 else {
                return 1
            }

            var res: UInt = 1
            for _ in 0..<pow {
                res *= base
            }

            return res
        }

        let baseDelay = min(self.config.cap, self.config.base * Double(uintPow(self.config.exp, self.retryCount)))
        let jitterDelay = TimeInterval.random(in: 0..<baseDelay)
        let delay = max(self.config.minDelay, jitterDelay)

        self.retryCount += 1

        return delay
    }
}
