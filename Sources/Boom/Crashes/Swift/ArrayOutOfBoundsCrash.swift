//
//  ArrayOutOfBoundsCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class ArrayOutOfBoundsCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .swiftRuntime
    public let title = "Array out of bounds"
    public let crashDescription = "Access index 10 on a 3-element array. Swift traps with EXC_BAD_INSTRUCTION."

    public init() {}

    public func trigger() -> Never {
        let array = [1, 2, 3]
        _ = array[10]
        fatalError("unreachable")
    }
}
