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
#if !os(watchOS)
import SystemConfiguration
#endif

/// Reachability
public class Reachability: ReachabilityProtocol {
    /// Blocks threads till network becomes reachable, or till timeoutDate has come
    ///
    /// - Parameters:
    ///   - timeoutDate: timeout date
    ///   - url: request url
    /// - Throws: NetworkRetryOperationError.reachabilityError, NetworkRetryOperationError.timeout
    public func waitTillReachable(timeoutDate: Date, url: String) throws {
    #if os(watchOS)
        // Not supported
        throw NetworkRetryOperationError.reachabilityError
    #else
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &address, { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            throw NetworkRetryOperationError.reachabilityError
        }

        let queue = DispatchQueue(label: "RetryQueue")

        guard SCNetworkReachabilitySetDispatchQueue(reachability, queue) else {
            throw NetworkRetryOperationError.reachabilityError
        }

        class Context: NSObject {
            let urlString: String
            var condition = NSCondition()

            init(urlString: String) {
                self.urlString = urlString

                super.init()
            }
        }

        let context = Context(urlString: url)

        var info = SCNetworkReachabilityContext(version: 0,
                                                info: Unmanaged.passUnretained(context).toOpaque(),
                                                retain: nil,
                                                release: nil,
                                                copyDescription: nil)

        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info = info else {
                fatalError()
            }

            let context = Unmanaged<Context>.fromOpaque(info).takeUnretainedValue()

            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            let canConnectAutomatically = flags.contains(.connectionOnDemand)
                || flags.contains(.connectionOnTraffic)
            let canConnectWithoutUserInteraction = canConnectAutomatically
                && !flags.contains(.interventionRequired)

            if isReachable && (!needsConnection || canConnectWithoutUserInteraction) {
                Log.debug("Retrying request to \(context.urlString) connection restored")
                context.condition.signal()
            }
        }

        guard SCNetworkReachabilitySetCallback(reachability, callback, &info) else {
            throw NetworkRetryOperationError.reachabilityError
        }

        let waitResult = context.condition.wait(until: timeoutDate)

        SCNetworkReachabilitySetCallback(reachability, nil, nil)

        guard waitResult else {
            Log.debug("Retrying request to \(context.urlString) connection timeout")
            throw NetworkRetryOperationError.timeout
        }
    #endif
    }
}
