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

import Foundation

public class Timer {
    private let interval: TimeInterval
    private let timer: DispatchSourceTimer

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    public init(interval: TimeInterval,
                repeating: Bool = true,
                startFromNow: Bool = true,
                handler: @escaping () -> Void) {
        self.interval = interval

        let timer = DispatchSource.makeTimerSource()

        let startAfter = startFromNow ? 0 : self.interval
        
        if repeating {
            timer.schedule(deadline: .now() + startAfter,
                           repeating: self.interval)
        }
        else {
            timer.schedule(deadline: .now() + startAfter)
        }

        timer.setEventHandler(handler: handler)

        self.timer = timer
    }

    deinit {
        self.timer.setEventHandler {}
        self.timer.cancel()

        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */

        self.resume()
    }

    public func resume() {
        if self.state == .resumed {
            return
        }

        self.state = .resumed
        self.timer.resume()
    }

    public func suspend() {
        if self.state == .suspended {
            return
        }

        self.state = .suspended
        self.timer.suspend()
    }
}
