//
//  AsyncOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

public class AsyncOperation: Operation {
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

    override public func start() {
        guard !self.isCancelled else {
            self.state = .finished
            return
        }
        self.state = .ready
        self.main()
    }
    
    override public func main() {
        // Implement your async task here.
    }
}


