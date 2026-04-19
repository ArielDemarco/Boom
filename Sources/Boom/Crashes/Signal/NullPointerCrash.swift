//
//  NullPointerCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
public final class NullPointerCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Dereference NULL pointer"
    public let crashDescription = "Write to address 0x0 via an UnsafeMutablePointer. Produces EXC_BAD_ACCESS (SIGSEGV)."

    public init() {}

    public func trigger() -> Never {
        let ptr = UnsafeMutablePointer<UInt>(bitPattern: 0)
        ptr!.pointee = 1
        fatalError("unreachable")
    }
}
