//
//  StackOverflowCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class StackOverflowCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Stack overflow"
    public let crashDescription = "Infinite recursion exhausts the stack. Crashes with EXC_BAD_ACCESS (SIGSEGV) or EXC_BAD_INSTRUCTION."

    public init() {}

    public func trigger() -> Never {
        recurse()
    }

    @inline(never)
    private func recurse() -> Never {
        recurse()
    }
}
