//
//  GenericOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCrypto

public enum Result<T> {
    case success(T)
    case failure(Error)
}

@objc enum GenericOperationError: Int, Error {
    case timeout
    case noName
}

public class GenericOperation<T>: Operation {
    private(set) var result: Result<T>? = nil
    private let task: () throws -> (T)
    
    override public var isAsynchronous: Bool { return true }
    
    override public var isExecuting: Bool { return state == .executing }
    override public var isFinished:  Bool { return state == .finished }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    enum State: String {
        case ready     = "Ready"
        case executing = "Executing"
        case finished  = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }

    public init(task: @escaping () throws ->(T)) {
        self.task = task
    }

    override public func start() {
        guard !self.isCancelled else {
            self.state = .finished
            return
        }
        self.state = .ready
        self.main()
    }
    
    override public func main() {
        guard !self.isCancelled else {
            self.state = .finished
            return
        }
        self.state = .executing
        
        do {
            self.result = .success(try self.task())
        } catch {
            self.result = .failure(error)
        }
        
        defer { self.state = .finished }
    }

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
                completion(Result.failure(GenericOperationError.noName))
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
                completion(Result.failure(GenericOperationError.timeout))
            }
        }
    }

    public func startSync() -> Result<T> {
        var result: Result<T>
        do {
            result = .success(try self.task())
        } catch {
            result = .failure(error)
        }
        self.result = result
        
        return result
    }
}


