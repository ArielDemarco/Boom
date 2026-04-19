//
//  AssertionCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class AssertionCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Assertion failure"
    public let crashDescription = "Call assertionFailure(). Only crashes in debug builds; in release, use preconditionFailure instead."

    public init() {}

    public func trigger() -> Never {
        assertionFailure("Triggered by Boom")
        fatalError("unreachable")
    }
}
