//
//  DivisionByZeroCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class DivisionByZeroCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Division by zero"
    public let crashDescription = "Divide an integer by zero. Swift traps with EXC_BAD_INSTRUCTION (not a floating-point exception)."

    public init() {}

    public func trigger() -> Never {
        let zero = Int.random(in: 0..<1)
        let result = 1 / zero
        _ = result
        fatalError("unreachable")
    }
}
