//
//  ObjCMsgSendCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class ObjCMsgSendCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .memory
    public let title = "ObjC msg send on zombie"
    public let crashDescription = "Send a message to a deallocated ObjC object. Produces EXC_BAD_ACCESS; enable Zombies to see the object class."

    public init() {}

    public func trigger() -> Never {
        boom_crash_objc_msg_send()
        fatalError("unreachable")
    }
}
