//
// Copyright (C) 2015-2021 Virgil Security Inc.
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
/// - timeout: Timeout has fired
/// - resultIsMissing: Result variable is empty after execution
/// - missingDependencies: Dependend operation result not found
/// - dependencyFailed: Dependend operation has failed
/// - operationCancelled: Operation was cancelled
@objc(VSSGenericOperationError) public enum GenericOperationError: Int, LocalizedError {
    case timeout = 1
    case resultIsMissing = 2
    case missingDependencies = 3
    case dependencyFailed = 4
    case operationCancelled = 5

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .timeout:
            return "Timeout has fired"
        case .resultIsMissing:
            return "Result variable is empty after execution"
        case .missingDependencies:
            return "Dependend operation result not found"
        case .dependencyFailed:
            return "Dependend operation has failed"
        case .operationCancelled:
            return "Operation was cancelled"
        }
    }
}

/// Represents AsyncOperation with Generic result
open class GenericOperation<T>: AsyncOperation {
    /// Operation Result
    /// WARNING: Do not modify this value outside of GenericOperation functions
    public var result: Result<T, Error>? = nil {
        didSet {
            if let result = self.result,
                case .failure(let error) = result {
                    self.error = error
            }
        }
    }

    /// Creates OperationQueue and starts operation
    ///
    /// - Parameter completion: Completion callback
    public func start(completion: @escaping (Result<T, Error>) -> Void) {
        guard !self.isCancelled else {
            self.finish()
            return
        }

        let queue = OperationQueue()

        self.completionBlock = {
            guard let result = self.result else {
                let error: Error

                if self.isCancelled {
                    error = GenericOperationError.operationCancelled
                }
                else {
                    error = GenericOperationError.resultIsMissing
                }

                let result: Result<T, Error> = Result.failure(error)
                self.result = result

                completion(result)
                return
            }
            completion(result)
        }

        queue.addOperation(self)
    }

    /// Creates OperationQueue and starts operation
    ///
    /// - Parameter completion: Completion callback
    public func start(completion: @escaping (T?, Error?) -> Void) {
        self.start { result in
            switch result {
            case .success(let res):
                completion(res, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    /// Creates queue, starts operation, waits for result, returns result
    ///
    /// - Parameter timeout: Operation timeout
    /// - Returns: Operation Result
    public func startSync(timeout: TimeInterval? = nil) -> Result<T, Error> {
        let queue = OperationQueue()

        queue.addOperation(self)

        if let timeout = timeout {
            let deadlineTime = DispatchTime.now() + timeout

            DispatchQueue.global(qos: .background).asyncAfter(deadline: deadlineTime) {
                let result: Result<T, Error> = Result.failure(GenericOperationError.timeout)
                self.result = result
                queue.cancelAllOperations()
            }
        }

        queue.waitUntilAllOperationsAreFinished()

        guard let result = self.result else {
            let error: Error

            if self.isCancelled {
                error = GenericOperationError.operationCancelled
            }
            else {
                error = GenericOperationError.resultIsMissing
            }

            let result: Result<T, Error> = Result.failure(error)
            self.result = result
            return result
        }

        return result
    }
}
