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

/// Mutex error
///
/// - unknownError: unknown error
public enum MutexError: Error {
    case unknownError(pthreadErrorCode: Int32)
}

/// Mutex
@objc(VSSMutex) open class Mutex: NSObject {
    private var mutex = pthread_mutex_t()

    /// Init
    @objc override public init() {
        pthread_mutex_init(&self.mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&self.mutex)
    }

    /// Tries to lock mutex
    ///
    /// - Returns: true if lock succeeded, false - otherwise
    @objc public func trylock() -> Bool {
        return pthread_mutex_trylock(&self.mutex) == 0
    }

    /// Locks mutex
    ///
    /// - Throws: MutexError
    @objc public func lock() throws {
        let result = pthread_mutex_lock(&self.mutex)

        guard result == 0 else {
            throw MutexError.unknownError(pthreadErrorCode: result)
        }
    }

    /// Unlocks mutex
    ///
    /// - Throws: MutexError
    @objc public func unlock() throws {
        let result = pthread_mutex_unlock(&self.mutex)

        guard result == 0 else {
            throw MutexError.unknownError(pthreadErrorCode: result)
        }
    }

    /// Executes closure synchronously
    ///
    /// - Parameter closure: closure to run
    /// - Throws: MutexError
    @objc public func executeSync(closure: () -> Void) throws {
        try self.lock()

        closure()

        try self.unlock()
    }

    /// Executes closure synchronously
    ///
    /// - Parameter closure: closure to run
    /// - Throws:
    ///    - MutexError
    ///    - Rethrows from closure
    public func executeSync(closure: () throws -> Void) throws {
        try self.lock()

        do {
            try closure()
        }
        catch {
            try self.unlock()
            throw error
        }

        try self.unlock()
    }
}
