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

@objc enum GenericOperationError: Int, Error {
    case timeout
    case noName
}

public class GenericOperation<T>: AsyncOperation {
    internal(set) var result: Result<T>? = nil
    
    public func start(timeout: Int? = nil, completion: @escaping (Result<T>)->()) {
        guard !self.isCancelled else {
            self.state = .finished
            return
        }
        self.state = .ready
        
        let group = DispatchGroup()
        
        group.enter()
        self.main()
        group.leave()
        
        group.notify(queue: DispatchQueue.main) {
            guard let result = self.result else {
                self.result = Result.failure(GenericOperationError.noName)
                completion(self.result!)
                return
            }
            completion(result)
        }
        
        guard let timeout = timeout else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
            if self.state == .executing {
                self.cancel()
                self.result = Result.failure(GenericOperationError.timeout)
                completion(self.result!)
            }
        }
    }
    
    public func startSync() -> Result<T> {
        let group = DispatchGroup()
        
        group.enter()
        self.main()
        group.leave()
        
        group.wait()
        
        guard let result = self.result else {
            self.result = Result.failure(GenericOperationError.noName)
            return self.result!
        }
        
        return result
    }
}



