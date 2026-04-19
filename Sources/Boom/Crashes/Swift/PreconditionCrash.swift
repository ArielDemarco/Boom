//
//  PreconditionCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class PreconditionCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Precondition failure"
    public let crashDescription = "Call preconditionFailure(). Crashes in both debug and release builds."

    public init() {}

    public func trigger() -> Never {
        preconditionFailure("Triggered by Boom")
    }
}
