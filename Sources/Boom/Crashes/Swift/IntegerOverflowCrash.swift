//
//  IntegerOverflowCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class IntegerOverflowCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Integer overflow"
    public let crashDescription = "Add 1 to Int.max via checked arithmetic. Swift traps with EXC_BAD_INSTRUCTION."

    public init() {}

    public func trigger() -> Never {
        // Use runtime value to prevent compile-time detection
        var value = Int.max
        value = value &+ Int.random(in: 1...1)  // always 1, but opaque to the optimizer
        let (result, overflow) = value.addingReportingOverflow(1)
        if overflow {
            // Force the actual trap: Swift's + operator traps on overflow
            _ = value + 1
        }
        _ = result
        fatalError("unreachable")
    }
}
