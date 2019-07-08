//
// Copyright (C) 2015-2019 Virgil Security Inc.
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

import VirgilSDK
import XCTest

class VSS013_MutexTests: XCTestCase {
    func test__nothing__thread_unsafe() {
        let counter = 2
        
        var i = 0
        
        var queues: [DispatchQueue] = []
        
        for j in 0..<counter {
            queues.append(DispatchQueue(label: "\(j)"))
        }
        
        for j in 0..<counter {
            queues[j].async {
                let k = i
                
                sleep(1)
                
                i = k + 1
            }
        }
        
        sleep(UInt32(2 * counter))
        
        XCTAssert(i != counter)
    }
    
    func test__lock_unlock__thread_unsafe() {
        let counter = 2
        
        
        var i = 0
        
        var queues: [DispatchQueue] = []
        
        for j in 0..<counter {
            queues.append(DispatchQueue(label: "\(j)"))
        }
        
        let mutex = Mutex()
        
        for j in 0..<counter {
            queues[j].async {
                try! mutex.executeSync {
                    let k = i
                    
                    sleep(1)
                    
                    i = k + 1
                }
            }
        }
        
        sleep(UInt32(2 * counter))
        
        XCTAssert(i == counter)
    }
}
