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

public enum Retry {
    case noRetry
    case retryService(delay: TimeInterval)
    case retryAuth
}

open class RetryTimer {
    open private(set) var retryCount: Int = 0
    public let maxRetryCount: Int = 3
    public let cap: TimeInterval = 10
    public let minDelay: TimeInterval = 0
    public let base: TimeInterval = 1

    open func retryTime(for response: Response) -> Retry {
        if 200..<400 ~= response.statusCode {
            return .noRetry
        }

        if 500..<600 ~= response.statusCode {
            if self.retryCount >= self.maxRetryCount {
                return .noRetry
            }

            let delay = self.nextRetryDelay()

            self.retryCount += 1

            return .retryService(delay: delay)
        }

        if 400..<500 ~= response.statusCode {
            if response.statusCode == 401 {
                // FIXME: Check if error is 401.20304

                return .retryAuth
            }
        }

        return .noRetry
    }

    open func nextRetryDelay() -> TimeInterval {
        let baseDelay = min(self.cap, self.base * pow(TimeInterval(2), TimeInterval(self.retryCount)))
        let jitterDelay = TimeInterval.random(in: 0..<baseDelay)
        let delay = max(self.minDelay, jitterDelay)

        return delay
    }
}
