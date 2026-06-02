//
//  ScheduledStartupCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

extension CrashRegistry {

    /// Schedules a crash to fire on the next app launch, before `main()` runs.
    /// The crash is cleared before firing, so it only occurs once.
    ///
    /// - Note: `OOMKillCrash` cannot be triggered pre-main (jetsam-only);
    ///   scheduling it will produce `EXC_BAD_INSTRUCTION` instead.
    public func scheduleStartupCrash(_ crash: any Crash) {
        startupStorage.schedule(String(describing: type(of: crash)))
    }

    public var hasScheduledStartupCrash: Bool {
        startupStorage.pendingIdentifier() != nil
    }

    public func cancelScheduledStartupCrash() {
        startupStorage.clear()
    }

    public var scheduledStartupCrash: (any Crash)? {
        guard let id = startupStorage.pendingIdentifier() else { return nil }
        return crashes.first { String(describing: type(of: $0)) == id }
    }
}
