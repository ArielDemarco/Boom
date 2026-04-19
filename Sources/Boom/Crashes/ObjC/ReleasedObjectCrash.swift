//
//  ReleasedObjectCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class ReleasedObjectCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .memory
    public let title = "Access released object"
    public let crashDescription = "Corrupt an object's isa pointer and call a method on it. Crashes in the ObjC runtime during method lookup."

    public init() {}

    public func trigger() -> Never {
        boom_crash_released_object()
        fatalError("unreachable")
    }
}
