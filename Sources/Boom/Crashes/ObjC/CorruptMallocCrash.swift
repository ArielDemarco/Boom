//
//  CorruptMallocCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class CorruptMallocCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .memory
    public let title = "Corrupt malloc metadata"
    public let crashDescription = "Write before a malloc'd buffer to corrupt the heap metadata, then free it. Crashes inside malloc/free."

    public init() {}

    public func trigger() -> Never {
        boom_crash_corrupt_malloc()
        fatalError("unreachable")
    }
}
