//
//  StackSmashCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class StackSmashCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Stack smash"
    public let crashDescription = "Writes past a stack buffer to corrupt the stack canary. Detected by __stack_chk_fail on return, producing SIGABRT with a distinct low-level stack trace."

    public init() {}

    public func trigger() -> Never {
        boom_crash_stack_smash()
        fatalError("unreachable")
    }
}
