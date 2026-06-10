//
//  BoomCrashExtension.swift
//  BoomCrashExtension
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if !targetEnvironment(simulator)
import CrashReportExtension
import os

private let log = Logger(subsystem: "com.ademarco.boomapp.crash-extension", category: "CrashReporter")

@main
struct BoomCrashExtension: CrashReporterExtension {
    func processCrashReport(process: CrashedProcess) {
        log.info("processCrashReport invoked with exception: \(process.reason.exception), codes: \(process.reason.codes)")
        let capturer = CrashReportCapturer(process: process)
        let sema = DispatchSemaphore(value: 0)
        Task.detached(priority: .userInitiated) {
            await capturer.captureAndSave()
            sema.signal()
        }
        sema.wait()
        log.info("processCrashReport finished")
    }
}
#else
import ExtensionFoundation
import Foundation

// CrashReportExtension is unavailable in the simulator SDK (Feedback FB23019442)
// This stub satisfies the __swift5_entry section requirement for ExtensionKit.
struct _NoOpConfiguration: AppExtensionConfiguration {
    func accept(connection: NSXPCConnection) -> Bool { false }
}

@main
struct BoomCrashExtension: AppExtension {
    var configuration: _NoOpConfiguration { _NoOpConfiguration() }
    init() {}
}
#endif
