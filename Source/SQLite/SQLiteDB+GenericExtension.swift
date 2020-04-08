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

// swiftlint:disable function_parameter_count
// swiftlint:disable large_tuple

extension SQLiteDB {
    internal func bindIn
        <T>
        (stmt: Statement,
         value: T?) throws
        where T: DbInValue {
                try self.bindIn(stmt: stmt, index: 1, value: value)
    }

    internal func bindIn
        <T1, T2>
        (stmt: Statement,
         value1: T1?,
         value2: T2?) throws
        where T1: DbInValue,
              T2: DbInValue {
                try self.bindIn(stmt: stmt, index: 1, value: value1)
                try self.bindIn(stmt: stmt, index: 2, value: value2)
    }

    internal func bindIn
        <T1, T2, T3>
        (stmt: Statement,
         value1: T1?,
         value2: T2?,
         value3: T3?) throws
        where T1: DbInValue,
              T2: DbInValue,
              T3: DbInValue {
                try self.bindIn(stmt: stmt, index: 1, value: value1)
                try self.bindIn(stmt: stmt, index: 2, value: value2)
                try self.bindIn(stmt: stmt, index: 3, value: value3)
    }

    internal func bindIn
        <T1, T2, T3, T4>
        (stmt: Statement,
         value1: T1?,
         value2: T2?,
         value3: T3?,
         value4: T4?) throws
        where T1: DbInValue,
        T2: DbInValue,
        T3: DbInValue,
        T4: DbInValue {
            try self.bindIn(stmt: stmt, index: 1, value: value1)
            try self.bindIn(stmt: stmt, index: 2, value: value2)
            try self.bindIn(stmt: stmt, index: 3, value: value3)
            try self.bindIn(stmt: stmt, index: 4, value: value4)
    }

    internal func bindIn
        <T1, T2, T3, T4, T5>
        (stmt: Statement,
         value1: T1?,
         value2: T2?,
         value3: T3?,
         value4: T4?,
         value5: T5?) throws
        where T1: DbInValue,
        T2: DbInValue,
        T3: DbInValue,
        T4: DbInValue,
        T5: DbInValue {
            try self.bindIn(stmt: stmt, index: 1, value: value1)
            try self.bindIn(stmt: stmt, index: 2, value: value2)
            try self.bindIn(stmt: stmt, index: 3, value: value3)
            try self.bindIn(stmt: stmt, index: 4, value: value4)
            try self.bindIn(stmt: stmt, index: 5, value: value5)
    }

    internal func bindIn
        <T1, T2, T3, T4, T5, T6>
        (stmt: Statement,
         value1: T1?,
         value2: T2?,
         value3: T3?,
         value4: T4?,
         value5: T5?,
         value6: T6?) throws
        where T1: DbInValue,
              T2: DbInValue,
              T3: DbInValue,
              T4: DbInValue,
              T5: DbInValue,
              T6: DbInValue {
                try self.bindIn(stmt: stmt, index: 1, value: value1)
                try self.bindIn(stmt: stmt, index: 2, value: value2)
                try self.bindIn(stmt: stmt, index: 3, value: value3)
                try self.bindIn(stmt: stmt, index: 4, value: value4)
                try self.bindIn(stmt: stmt, index: 5, value: value5)
                try self.bindIn(stmt: stmt, index: 6, value: value6)
    }
}

extension SQLiteDB {
    internal func bindOut
        <T>(stmt: Statement) throws
        -> T? where T: DbOutValue {
            return self.bindOut(stmt: stmt, index: 0)
    }

    internal func bindOut
        <T1, T2>
        (stmt: Statement) throws
        -> (T1?, T2?)
        where T1: DbOutValue,
        T2: DbOutValue {
            let res1: T1? = self.bindOut(stmt: stmt, index: 0)
            let res2: T2? = self.bindOut(stmt: stmt, index: 1)

            return (res1, res2)
    }

    internal func bindOut
        <T1, T2, T3>
        (stmt: Statement) throws
        -> (T1?, T2?, T3?)
        where T1: DbOutValue,
        T2: DbOutValue,
        T3: DbOutValue {
            let res1: T1? = self.bindOut(stmt: stmt, index: 0)
            let res2: T2? = self.bindOut(stmt: stmt, index: 1)
            let res3: T3? = self.bindOut(stmt: stmt, index: 2)

            return (res1, res2, res3)
    }

    internal func bindOut
        <T1, T2, T3, T4>
        (stmt: Statement) throws
        -> (T1?, T2?, T3?, T4?)
        where T1: DbOutValue,
        T2: DbOutValue,
        T3: DbOutValue,
        T4: DbOutValue {
            let res1: T1? = self.bindOut(stmt: stmt, index: 0)
            let res2: T2? = self.bindOut(stmt: stmt, index: 1)
            let res3: T3? = self.bindOut(stmt: stmt, index: 2)
            let res4: T4? = self.bindOut(stmt: stmt, index: 3)

            return (res1, res2, res3, res4)
    }

    internal func bindOut
        <T1, T2, T3, T4, T5>
        (stmt: Statement) throws
        -> (T1?, T2?, T3?, T4?, T5?)
        where T1: DbOutValue,
        T2: DbOutValue,
        T3: DbOutValue,
        T4: DbOutValue,
        T5: DbOutValue {
            let res1: T1? = self.bindOut(stmt: stmt, index: 0)
            let res2: T2? = self.bindOut(stmt: stmt, index: 1)
            let res3: T3? = self.bindOut(stmt: stmt, index: 2)
            let res4: T4? = self.bindOut(stmt: stmt, index: 3)
            let res5: T5? = self.bindOut(stmt: stmt, index: 4)

            return (res1, res2, res3, res4, res5)
    }

    internal func bindOut
        <T1, T2, T3, T4, T5, T6>
        (stmt: Statement) throws
        -> (T1?, T2?, T3?, T4?, T5?, T6?)
        where T1: DbOutValue,
              T2: DbOutValue,
              T3: DbOutValue,
              T4: DbOutValue,
              T5: DbOutValue,
              T6: DbOutValue {
                let res1: T1? = self.bindOut(stmt: stmt, index: 0)
                let res2: T2? = self.bindOut(stmt: stmt, index: 1)
                let res3: T3? = self.bindOut(stmt: stmt, index: 2)
                let res4: T4? = self.bindOut(stmt: stmt, index: 3)
                let res5: T5? = self.bindOut(stmt: stmt, index: 4)
                let res6: T6? = self.bindOut(stmt: stmt, index: 5)

                return (res1, res2, res3, res4, res5, res6)
    }
}
