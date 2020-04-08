//
// Copyright (C) 2015-2020 Virgil Security Inc.
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
import SQLite3

/// Represents error of SQLite Binding
///
/// - invalidString: Invalid String
@objc(VTESQLiteBindingError) public enum SQLiteBindingError: Int, LocalizedError {
    case invalidString = 1

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .invalidString:
            return "Invalid String"
        }
    }
}

extension Data: DbInValue, DbOutValue {
    internal init?(stmt: Statement, index: Int32) {
        let len = Int(sqlite3_column_bytes(stmt.stmt, index))

        guard len != 0 else {
            self.init()
            return
        }

        guard let queryResult = sqlite3_column_blob(stmt.stmt, index) else {
            return nil
        }

        self.init(bytes: queryResult, count: len)
    }

    internal func dumpTo(stmt: Statement, index: Int32) throws {
        let res = self.withUnsafeBytes {
            sqlite3_bind_blob(stmt.stmt, index, $0.baseAddress, Int32($0.count), nil)
        }

        guard res == SQLITE_OK else {
            throw SQLiteError(errorNum: res)
        }
    }
}

extension String: DbInValue, DbOutValue {
    internal init?(stmt: Statement, index: Int32) {
        let len = Int(sqlite3_column_bytes(stmt.stmt, index))

        guard len != 0 else {
            self.init()
            return
        }

        guard let queryResult = sqlite3_column_text(stmt.stmt, index) else {
            return nil
        }

        self.init(cString: queryResult)
    }

    internal func dumpTo(stmt: Statement, index: Int32) throws {
        guard let utf8Text = (self as NSString).utf8String else {
            throw SQLiteBindingError.invalidString
        }

        let res = sqlite3_bind_text(stmt.stmt, index, utf8Text, -1, nil)

        guard res == SQLITE_OK else {
            throw SQLiteError(errorNum: res)
        }
    }
}

extension Bool: DbInValue, DbOutValue {
    internal init?(stmt: Statement, index: Int32) {
        let int = sqlite3_column_int(stmt.stmt, index)

        self = int == 0 ? false : true
    }

    internal func dumpTo(stmt: Statement, index: Int32) throws {
        let res = sqlite3_bind_int(stmt.stmt, index, self ? 1 : 0)

        guard res == SQLITE_OK else {
            throw SQLiteError(errorNum: res)
        }
    }

}
