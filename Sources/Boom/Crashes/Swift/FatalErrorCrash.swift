//
//  FatalErrorCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class FatalErrorCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "fatalError()"
    public let crashDescription = "Call fatalError() with a message. Produces EXC_BAD_INSTRUCTION with the message in the crash report."

    public init() {}

    public func trigger() -> Never {
        fatalError("Triggered by Boom")
    }
}
