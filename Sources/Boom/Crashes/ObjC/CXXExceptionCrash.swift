//
//  CXXExceptionCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class CXXExceptionCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .exception
    public let title = "Throw C++ exception"
    public let crashDescription = "Throw an uncaught std::runtime_error. No NSUncaughtExceptionHandler; crash reporters must use a terminate() hook."

    public init() {}

    public func trigger() -> Never {
        boom_crash_cxx_exception()
        fatalError("unreachable")
    }
}
