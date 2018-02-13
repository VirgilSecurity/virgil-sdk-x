//
//  SignModelOperationFabric.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

public final class SignModelOperationFabric {
    public let callback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)

    public init(callback: @escaping ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)) {
        self.callback = callback
    }

    public func makeOperation(for rawSignedModel: RawSignedModel) -> GenericOperation<RawSignedModel> {
        return CallbackOperation<RawSignedModel>(task: { _, completion in
            self.callback(rawSignedModel, completion)
        })
    }
}
