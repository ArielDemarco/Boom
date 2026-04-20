//
//  KVOCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class KVOCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .exception
    public let title = "KVO: remove unregistered observer"
    public let crashDescription = "Calls removeObserver:forKeyPath: for an observer that was never registered. Throws NSInternalInconsistencyException."

    public init() {}

    public func trigger() -> Never {
        boom_crash_kvo()
        fatalError("unreachable")
    }
}
