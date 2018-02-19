//
//  AsyncOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class for AsyncOperations
open class AsyncOperation: Operation {
    /// Operation error
    open var error: Error?
    /// Overrides Operation variable
    override open var isAsynchronous: Bool { return true }
    /// Overrides Operation variable
    override open var isExecuting: Bool { return self.state == .executing }
    /// Overrides Operation variable
    override open var isFinished: Bool { return self.state == .finished }
    /// Operation state
    private var state = State.ready {
        willSet {
            self.willChangeValue(forKey: self.state.keyPath)
            self.willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            self.didChangeValue(forKey: self.state.keyPath)
            self.didChangeValue(forKey: oldValue.keyPath)
        }
    }

    /// Describes Operation state
    public enum State: String {
        case ready     = "Ready"
        case executing = "Executing"
        case finished  = "Finished"

        fileprivate var keyPath: String { return "is" + self.rawValue }
    }

    /// Overrides Operation function
    /// WARNING: You do not need override this function. Override main() func instead
    override open func start() {
        guard !self.isCancelled else {
            self.state = .finished
            return
        }

        self.state = .executing
        self.main()
    }

    /// Call this function when you task is finished
    /// WARNING: You do not need override this function. Override main() func instead
    open func finish() {
        self.state = .finished
    }

    /// Implement your task here
    override open func main() {
    }
}
