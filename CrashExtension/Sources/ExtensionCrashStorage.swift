//
//  ExtensionCrashStorage.swift
//  BoomCrashExtension
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import os

private let log = Logger(subsystem: "com.ademarco.boomapp.crash-extension", category: "Storage")

struct ExtensionCrashStorage {
    static let appGroupID = "group.com.ademarco.boomapp"
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func save(_ payload: ExtensionCrashPayload, exception: Int) {
        let container = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        )
        log.info("App Group container: \(container?.path ?? "nil")")
        
        guard let container else { return }
        
        do {
            let dir = container.appendingPathComponent("crashes", isDirectory: true)
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
            
            let id = UUID()
            let epochMs = Int(Date().timeIntervalSince1970 * 1000)
            let filename = "ext_\(id.uuidString)_\(epochMs)_nil_\(exception).json"
            let dest = dir.appendingPathComponent(filename)
            
            guard let data = try? JSONEncoder().encode(payload) else {
                log.error("Failed to encode payload")
                return
            }
            
            try data.write(to: dest, options: .atomic)
            log.info("Crash report saved: \(filename)")
        } catch {
            log.error("Failed to write crash report: \(error)")
        }
    }
}
