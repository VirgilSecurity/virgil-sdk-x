//
//  CallbackOperation.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/19/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

public class CallbackOperation<T>: GenericOperation<T> {
    private let task: () throws -> (T)

    public init(task: @escaping () throws ->(T)) {
        self.task = task
    }

    override public func main() {
        var tmpResult: Result<T>
        do {
            tmpResult = .success(try self.task())
        } catch {
            tmpResult = .failure(error)
        }

        guard !self.isCancelled else {
            self.state = .finished
            return
        }

        self.result = tmpResult

        self.state = .finished
    }
}
