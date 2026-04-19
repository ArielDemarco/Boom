//
//  Process+Extension.swift
//  Boom
//
//  Created by Ariel Demarco on 19/04/2026.
//

#if os(macOS)
import Foundation

extension Process {
    /// Returns true if the process exits within `seconds`, false if it's still running.
    func poll(within seconds: TimeInterval) -> Bool {
        let deadline = Date(timeIntervalSinceNow: seconds)
        while isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        return !isRunning
    }
}
#endif
