//
//  CallbackOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/19/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCallbackOperationError) public enum CallbackOperationError: Int, Error {
    case errorAndResultMissing = 1
}

public class CallbackOperation<T>: GenericOperation<T> {
    public typealias Task = (CallbackOperation<T>, @escaping (T?, Error?) -> Void) -> Void
    
    public let task: Task

    public init(task: @escaping Task) {
        self.task = task
        
        super.init()
    }

    override public func main() {
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
