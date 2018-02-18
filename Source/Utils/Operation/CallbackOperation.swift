//
//  CallbackOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/19/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Declares error types and codes
///
/// - errorAndResultMissing: Both Result and Error are missing in callback
@objc(VSSCallbackOperationError) public enum CallbackOperationError: Int, Error {
    case errorAndResultMissing = 1
}

/// Async GenericOperation that can be initialized with callback
open class CallbackOperation<T>: GenericOperation<T> {
    /// Task type
    public typealias Task = (CallbackOperation<T>, @escaping (T?, Error?) -> Void) -> Void

    /// Task to execute
    public let task: Task

    /// Initializer
    ///
    /// - Parameter task: task to execute
    public init(task: @escaping Task) {
        self.task = task

        super.init()
    }

    /// Main function
    override open func main() {
        self.task(self) { res, error in
            if let res = res {
                self.result = .success(res)
            }
            else if let error = error {
                self.result = .failure(error)
            }
            else {
                self.result = .failure(CallbackOperationError.errorAndResultMissing)
            }

            self.finish()
        }
    }
}
