//
//  GenericOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

@objc(VSSGenericOperationError) public enum GenericOperationError: Int, Error {
    case timeout = 1
    case resultIsMissing = 2
    case missingDependencies = 3
    case dependencyFailed = 4
}

public class GenericOperation<T>: AsyncOperation {
    internal(set) var result: Result<T>? = nil

    public func start(completion: @escaping (Result<T>) -> ()) {
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

    public func startSync(timeout: TimeInterval? = nil) -> Result<T> {
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

public extension GenericOperation {
    func findDependencyResult<T>() throws -> T {
        guard let operation = self.dependencies
            .first(where: { ($0 as? GenericOperation<T>)?.result != nil }) as? GenericOperation<T>,
            let operationResult = operation.result else {
                throw GenericOperationError.missingDependencies
        }

        guard case let .success(result) = operationResult else {
            throw GenericOperationError.dependencyFailed
        }

        return result
    }

    func findDependencyError<T>() -> T? {
        for dependency in self.dependencies {
            if let d = dependency as? GenericOperation,
                let res = d.result {
                    if case let .failure(error) = res {
                        if let e = error as? T {
                            return e
                        }
                    }
            }
        }

        return nil
    }
}
