//
//  StartupCrashStorage.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

final class StartupCrashStorage {
    static let `default` = StartupCrashStorage()

    private let fileURL: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.fileURL = directory.appendingPathComponent("boom_startup_crash")
    }

    func schedule(_ identifier: String) {
        try? fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? identifier.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    func pendingIdentifier() -> String? {
        try? String(contentsOf: fileURL, encoding: .utf8)
    }

    func clear() {
        try? fileManager.removeItem(at: fileURL)
    }
}
