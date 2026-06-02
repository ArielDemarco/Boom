//
//  ScheduledStartupCrashTests.swift
//  BoomTests
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import Boom

@MainActor
final class ScheduledStartupCrashTests: XCTestCase {

    private var tempDir: URL!
    private var registry: CrashRegistry!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        registry = CrashRegistry(startupStorage: StartupCrashStorage(directory: tempDir))
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDir)
    }

    func test_noPendingCrash_byDefault() {
        XCTAssertFalse(registry.hasScheduledStartupCrash)
    }

    func test_schedule_persistsPendingCrash() {
        registry.scheduleStartupCrash(AbortCrash())
        XCTAssertTrue(registry.hasScheduledStartupCrash)
    }

    func test_cancel_removesPendingCrash() {
        registry.scheduleStartupCrash(AbortCrash())
        registry.cancelScheduledStartupCrash()
        XCTAssertFalse(registry.hasScheduledStartupCrash)
    }

    func test_schedule_isOverwritable() {
        registry.scheduleStartupCrash(AbortCrash())
        registry.scheduleStartupCrash(FatalErrorCrash())
        XCTAssertTrue(registry.hasScheduledStartupCrash)
    }

    func test_schedule_writesCorrectIdentifier() {
        registry.scheduleStartupCrash(AbortCrash())
        let fileURL = tempDir.appendingPathComponent("boom_startup_crash")
        let contents = try? String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertEqual(contents, "AbortCrash")
    }
}
