//
//  DeadlockCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

public final class DeadlockCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .thread
    public let title = "Main thread deadlock"
    public let crashDescription = "Dispatch sync onto the main queue from the main thread. Produces a watchdog timeout (0x8badf00d) in production."

    public init() {}

    public func trigger() -> Never {
        DispatchQueue.main.sync {
            // never executes (deadlock)
        }
        fatalError("unreachable")
    }
}
