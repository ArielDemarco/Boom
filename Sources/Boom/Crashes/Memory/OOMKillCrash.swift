//
//  OOMKillCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

public final class OOMKillCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .memory
    public let title = "OOM kill (jetsam)"
    public let crashDescription = "Allocates 4 MB chunks in a loop until jetsam terminates the process. iOS OOM kills appear in jetsam logs but do not generate a traditional crash report."

    public init() {}

    public func trigger() -> Never {
        var buckets: [[UInt8]] = []
        while true {
            buckets.append(Array(repeating: 0, count: 4 * 1024 * 1024))
        }
    }
}
