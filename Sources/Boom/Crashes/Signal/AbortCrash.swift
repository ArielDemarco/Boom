//
//  AbortCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import Darwin

public final class AbortCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Call abort()"
    public let crashDescription = "Call abort() to send SIGABRT to the process."

    public init() {}

    public func trigger() -> Never {
        abort()
    }
}
