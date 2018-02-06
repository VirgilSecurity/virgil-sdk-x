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

@objc public enum GenericOperationError: Int, Error {
    case timeout = 1
    case unknown = 2
}

public class GenericOperation<T>: AsyncOperation {
    internal(set) var result: Result<T>? = nil

    public func start(completion: @escaping (Result<T>) -> ()) {
        guard !self.isCancelled else {
            self.state = .finished
            return
        }
        self.state = .ready

        let queue = OperationQueue()

        queue.addOperation {
            self.state = .executing
            self.main()
            guard let result = self.result else {
                let result: Result<T> = Result.failure(GenericOperationError.unknown)
                self.result = result

                completion(result)
                return
            }
            completion(result)
        }
    }

    public func startSync(timeout: Int? = nil) -> Result<T> {
        if let timeout = timeout {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
                if self.state == .executing {
                    self.cancel()
                    self.result = Result.failure(GenericOperationError.timeout)
                }
            }
        }
        let queue = OperationQueue()

        queue.addOperation {
            self.state = .executing
            self.main()
        }

        queue.waitUntilAllOperationsAreFinished()

        guard let result = self.result else {
            let result: Result<T> = Result.failure(GenericOperationError.unknown)
            self.result = result
            return result
        }

        return result
    }
}
