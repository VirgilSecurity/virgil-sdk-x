//
//  SignModelOperationFabric.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Generates GenerickOperation<RawSignedModel> with provided in initializer signcallback
public final class SignModelOperationFabric {
    /// Callback used for custom signing RawSignedModel, which takes RawSignedModel
    /// to sign and competion handler, called with signed RawSignedModel or provided error
    public let callback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)

    /// Initializer
    ///
    /// - Parameter callback: callback for custom signing RawSignedModel, which takes RawSignedModel
    ///   to sign and competion handler, called with signed RawSignedModel or provided error
    public init(callback: @escaping ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)) {
        self.callback = callback
    }

    /// Makes GenerickOperation<RawSignedModel> ready to perform custom signCallback
    ///
    /// - Parameter rawSignedModel: RawSignedModel to sign
    /// - Returns: GenerickOperation<RawSignedModel> ready to perform custom signCallback
    public func makeOperation(for rawSignedModel: RawSignedModel) -> GenericOperation<RawSignedModel> {
        return CallbackOperation<RawSignedModel>(task: { _, completion in
            self.callback(rawSignedModel, completion)
        })
    }
}
