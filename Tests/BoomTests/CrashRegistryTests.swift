//
//  CrashRegistryTests.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import XCTest
@testable import Boom

@MainActor
final class CrashRegistryTests: XCTestCase {

    func test_defaultCrashes_notEmpty() {
        XCTAssertFalse(CrashRegistry.shared.crashes.isEmpty)
    }

    func test_allCrashes_haveNonEmptyMetadata() {
        for crash in CrashRegistry.shared.crashes {
            XCTAssertFalse(crash.title.isEmpty, "title is empty for \(type(of: crash))")
            XCTAssertFalse(crash.crashDescription.isEmpty, "description is empty for \(type(of: crash))")
        }
    }

    func test_categoriesFilter_returnsCorrectSubset() {
        let signalCrashes = CrashRegistry.shared.crashes(in: .signal)
        XCTAssertFalse(signalCrashes.isEmpty)
        XCTAssertTrue(signalCrashes.allSatisfy { $0.category == .signal })
    }

    func test_allCategories_haveCrashes() {
        for category in CrashCategory.allCases {
            let crashes = CrashRegistry.shared.crashes(in: category)
            XCTAssertFalse(crashes.isEmpty, "No crashes registered for category: \(category.rawValue)")
        }
    }

    func test_crashTitles_areUnique() {
        let titles = CrashRegistry.shared.crashes.map(\.title)
        let unique = Set(titles)
        XCTAssertEqual(titles.count, unique.count, "Duplicate crash titles found")
    }

    func test_customCrash_canBeRegistered() {
        let registry = CrashRegistry.shared
        let before = registry.crashes.count

        registry.register(StubCrash())

        XCTAssertEqual(registry.crashes.count, before + 1)
    }
}

// MARK: - Helpers

private final class StubCrash: Crash, @unchecked Sendable {
    let category: CrashCategory = .swiftRuntime
    let title = "Stub crash for testing"
    let crashDescription = "Never actually crashes."
    func trigger() -> Never { fatalError("stub") }
}
