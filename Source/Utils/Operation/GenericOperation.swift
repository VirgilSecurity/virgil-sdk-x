//
//  GenericOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Declares error types and codes
///
/// - timeout: Timeout has fired
/// - resultIsMissing: Result variable is empty after execution
/// - missingDependencies: Dependend operation result not found
/// - dependencyFailed: Dependend operation has failed
@objc(VSSGenericOperationError) public enum GenericOperationError: Int, Error {
    case timeout = 1
    case resultIsMissing = 2
    case missingDependencies = 3
    case dependencyFailed = 4
}

/// Represents AsyncOperation with Generic result
open class GenericOperation<T>: AsyncOperation {
    /// Operation Result
    /// WARNING: Do not modify this value outside of GenericOperation functions
    public var result: Result<T>? = nil {
        didSet {
            if let result = self.result,
                case .failure(let error) = result {
                    self.error = error
            }
        }
    }

    /// Created OperationQueue and starts operation
    ///
    /// - Parameter completion: Completion callback
    open func start(completion: @escaping (Result<T>) -> ()) {
        guard !self.isCancelled else {
            // FIXME investigate cancellation
            self.cancel()
            return
        }

        let queue = OperationQueue()

        self.completionBlock = {
            guard let result = self.result else {
                let result: Result<T> = Result.failure(GenericOperationError.resultIsMissing)
                self.result = result

                completion(result)
                return
            }
            completion(result)
        }

        queue.addOperation(self)
    }

    /// Creates queue, starts operation, waits for result, returns result
    ///
    /// - Parameter timeout: Operation timeout
    /// - Returns: Operation Result
    open func startSync(timeout: TimeInterval? = nil) -> Result<T> {
        let queue = OperationQueue()

        queue.addOperation(self)

        // FIXME: Add tests
        if let timeout = timeout {
            let deadlineTime = DispatchTime.now() + timeout

            DispatchQueue.global(qos: .background).asyncAfter(deadline: deadlineTime) {
                queue.cancelAllOperations()
            }
        }

        queue.waitUntilAllOperationsAreFinished()

        guard let result = self.result else {
            let result: Result<T> = Result.failure(GenericOperationError.timeout)
            self.result = result
            return result
        }

        return result
    }
}
