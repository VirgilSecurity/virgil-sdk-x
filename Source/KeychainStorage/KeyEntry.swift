//
// Copyright (C) 2015-2021 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

@objc(VSSKeyEntry) public class KeyEntry: NSObject, NSCoding {

    public let name: String
    public let value: Data
    public let meta: [String: String]?

    private enum CodingKeys: String {
        case name = "name"
        case value = "value"
        case meta = "meta"
    }

    public init(name: String, value: Data, meta: [String: String]?) {
        self.name = name
        self.value = value
        self.meta = meta
    }

    public required init?(coder: NSCoder) {
        guard
            let name = coder.decodeObject(forKey: CodingKeys.name.rawValue) as? String,
            let value = coder.decodeObject(forKey: CodingKeys.value.rawValue) as? Data
        else {
            return nil
        }

        self.name = name
        self.value = value

        if coder.containsValue(forKey: CodingKeys.meta.rawValue) {
            self.meta = coder.decodeObject(forKey: CodingKeys.meta.rawValue) as? [String: String]
        }
        else {
            self.meta = nil
        }
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: CodingKeys.name.rawValue)
        coder.encode(self.value, forKey: CodingKeys.value.rawValue)

        if let meta = self.meta {
            coder.encode(meta, forKey: CodingKeys.meta.rawValue)
        }
    }
}
