//
//  ObjCExceptionCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class ObjCExceptionCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .exception
    public let title = "Throw ObjC exception"
    public let crashDescription = "Throw an uncaught NSException. NSUncaughtExceptionHandler captures the exception name and reason."

    public init() {}

    public func trigger() -> Never {
        boom_crash_objc_exception()
        fatalError("unreachable")
    }
}
