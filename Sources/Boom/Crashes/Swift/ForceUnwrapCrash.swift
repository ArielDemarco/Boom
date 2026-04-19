//
//  ForceUnwrapCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class ForceUnwrapCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Force unwrap nil"
    public let crashDescription = "Force-unwrap an Optional<Int> that is nil. Swift traps with EXC_BAD_INSTRUCTION."

    public init() {}

    public func trigger() -> Never {
        let value: Int? = nil
        _ = value!
        fatalError("unreachable")
    }
}
