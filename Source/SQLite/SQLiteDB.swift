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

// swiftlint:disable identifier_name

/// Represents error of SQLite
@objc(VTESQLiteError) public class SQLiteError: NSObject, LocalizedError {
    // Code of error
    public let errorNum: Int32?

    internal init(errorNum: Int32? = nil) {
        self.errorNum = errorNum

        super.init()
    }

    /// Error description
    @objc public var errorDescription: String? {
        guard let errorNum = self.errorNum else {
            return "Unknown SQLite error."
        }

        return String(cString: sqlite3_errstr(errorNum))
    }
}

internal class SQLiteDB {
    internal func generateStmt(statement: String) throws -> Statement {
        var stmt: OpaquePointer?

        let res = sqlite3_prepare_v2(self.handle, statement, -1, &stmt, nil)

        guard res == SQLITE_OK else {
            throw SQLiteError(errorNum: res)
        }

        guard let s = stmt else {
            throw SQLiteError()
        }

        return Statement(stmt: s)
    }

    private let handle: OpaquePointer

    internal let path: String

    internal init(prefix: String,
                  userIdentifier: String,
                  name: String) throws {
        var url = try FileManager.default.url(for: .applicationSupportDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: false)

        url.appendPathComponent(prefix)
        url.appendPathComponent(userIdentifier)

        try FileManager.default.createDirectory(at: url,
                                                withIntermediateDirectories: true,
                                                attributes: nil)

        url.appendPathComponent(name)

        var h: OpaquePointer?

        let path = url.absoluteString
        self.path = path

        let res = sqlite3_open_v2(path,
                                  &h,
                                  SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI,
                                  nil)

        guard res == SQLITE_OK else {
            throw SQLiteError(errorNum: res)
        }

        guard let handle = h else {
            throw SQLiteError()
        }

        self.handle = handle
    }

    internal func executeNoResult(statement: String) throws {
        let stmt = try self.generateStmt(statement: statement)

        try self.executeNoResult(statement: stmt)
    }

    internal func executeNoResult(statement: Statement) throws {
        let res = sqlite3_step(statement.stmt)

        guard res == SQLITE_DONE else {
            throw SQLiteError(errorNum: res)
        }
    }

    internal func executeStep(statement: Statement) throws -> Bool {
        let res = sqlite3_step(statement.stmt)

        switch res {
        case SQLITE_DONE:
            return false
        case SQLITE_ROW:
            return true

        default:
            throw SQLiteError(errorNum: res)
        }
    }

    internal func bindIn<T>(stmt: Statement, index: Int32, value: T?) throws where T: DbInValue {
        guard let value = value else {
            let res = sqlite3_bind_null(stmt.stmt, index)

            guard res == SQLITE_OK else {
                throw SQLiteError(errorNum: res)
            }

            return
        }

        try value.dumpTo(stmt: stmt, index: index)
    }

    internal func bindOut<T>(stmt: Statement, index: Int32) -> T? where T: DbOutValue {
        return T(stmt: stmt, index: index)
    }

    deinit {
        guard sqlite3_close(self.handle) == SQLITE_OK else {
            fatalError()
        }
    }
}
