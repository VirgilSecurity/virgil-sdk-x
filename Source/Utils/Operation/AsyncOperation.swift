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

    override public var isExecuting: Bool { return self.state == .executing }
    override public var isFinished: Bool { return self.state == .finished }

    public private(set) var state = State.ready {
        willSet {
            self.willChangeValue(forKey: self.state.keyPath)
            self.willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            self.didChangeValue(forKey: self.state.keyPath)
            self.didChangeValue(forKey: oldValue.keyPath)
        }
    }

    public enum State: String {
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

        self.state = .executing
        self.main()
    }
    
    open func finish() {
        self.state = .finished
    }

    override public func main() {
        // Implement your task here.
    }
}
