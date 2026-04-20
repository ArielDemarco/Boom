//
//  UnrecognizedSelectorCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import BoomObjC

public final class UnrecognizedSelectorCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .exception
    public let title = "Unrecognized selector"
    public let crashDescription = "Calls performSelector with a selector that does not exist on NSObject. Crashes in [NSObject doesNotRecognizeSelector:]."

    public init() {}

    public func trigger() -> Never {
        boom_crash_unrecognized_selector()
        fatalError("unreachable")
    }
}
