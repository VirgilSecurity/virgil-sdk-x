//
//  GenericOperation+Dependencies.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

// MARK: - Dependency-related operations
public extension GenericOperation {
    /// Finds first dependency with Result of correct type and returns its result,
    /// if operation has succeeded
    ///
    /// - Returns: Dependency Result
    /// - Throws: GenericOperationError.missingDependencies, if no dependency with correct type was found
    ///           GenericOperationError.dependencyFailed, if dependency has failed
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

    /// Finds dependency error
    ///
    /// - Returns: Dependency error
    func findDependencyError() -> Error? {
        for dependency in self.dependencies {
            if let dependency = dependency as? AsyncOperation,
                let error = dependency.error {
                    return error
            }
        }

        return nil
    }
}
