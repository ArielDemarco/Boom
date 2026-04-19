//
//  AsyncSafeThreadCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

public final class AsyncSafeThreadCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .thread
    public let title = "Crash inside async-safe thread"
    public let crashDescription = "Trigger a crash from a background thread to verify the reporter captures threads other than main."

    public init() {}

    public func trigger() -> Never {
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let ptr = UnsafeMutablePointer<UInt>(bitPattern: 0)
            ptr!.pointee = 1
            sema.signal()
        }
        sema.wait()
        fatalError("unreachable")
    }
}
