//
//  CrashRepository.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

final class CrashRepository: @unchecked Sendable {
    private let fileManager: FileManager
    private let defaults: UserDefaults
    private let directory: URL
    private let encoder: JSONEncoder = {
        let encoder: JSONEncoder = .init()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    private let decoder: JSONDecoder = .init()
    
    
    private static let readIDsKey = "boom.readCrashIDs"
    
    init(
        fileManager: FileManager = .default,
        defaults: UserDefaults = .init(suiteName: "com.ademarco.bombapp.crashes") ?? .standard
    ) {
        self.fileManager = fileManager
        self.defaults = defaults
        
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directory = documents.appendingPathComponent("crashes", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    
    // MARK: - Summaries
    
    func loadSummaries() -> [CrashReportSummary] {
        do {
            return try fileManager.contentsOfDirectory(atPath: directory.path)
                .compactMap { CrashReportSummary(
                    filename: $0,
                    isRead: isRead(UUID(uuidString: String($0.prefix(36))) ?? UUID())
                )}.sorted { $0.date > $1.date }
        } catch let exception {
            print(exception.localizedDescription)
            return []
        }
    }
    
    func save(payload: CrashReportPayload, filename: String) {
        do {
            let data = try encoder.encode(payload)
            try data.write(to: url(for: filename), options: .atomic)
        } catch let exception {
            print(exception.localizedDescription)
        }
    }
    
    func delete(_ summary: CrashReportSummary) {
        try? fileManager.removeItem(at: url(for: summary.filename))
    }
    
    func deleteAll(_ summaries: [CrashReportSummary]) {
        summaries.forEach { try? fileManager.removeItem(at: url(for: $0.filename)) }
        defaults.removeObject(forKey: Self.readIDsKey)
    }
    
    // MARK: - Payload
    
    func loadPayload(for summary: CrashReportSummary) -> CrashPayload? {
        guard let data = try? Data(contentsOf: url(for: summary.filename)) else { return nil }

        if let payload = try? decoder.decode(CrashReportPayload.self, from: data) {
            return .structured(payload)
        }
        
        let json = (try? JSONSerialization.jsonObject(with: data))
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }
            .flatMap { String(data: $0, encoding: .utf8) }
            ?? String(data: data, encoding: .utf8)
            ?? "{}"
        return .dump(json)
    }
    
    // MARK: - Read state
    
    func markRead(_ id: UUID) {
        var ids = readIDs
        ids.insert(id.uuidString)
        defaults.set(Array(ids), forKey: Self.readIDsKey)
    }
    
    func isRead(_ id: UUID) -> Bool {
        readIDs.contains(id.uuidString)
    }
    
    // MARK: - Extension import
    
    // Moves crash reports written by BoomCrashExtension from the App Group
    // shared container into the app's crashes directory so they appear in the
    // Reports tab alongside MetricKit reports.
    func importExtensionReports() {
        guard let container = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.ademarco.boomapp"
        ) else { return }
        
        do {
            let source = container.appendingPathComponent("crashes", isDirectory: true)
            let files = try fileManager.contentsOfDirectory(atPath: source.path)
            
            for filename in files where filename.hasSuffix(".json") {
                let from = source.appendingPathComponent(filename)
                let to = directory.appendingPathComponent(filename)
                try fileManager.moveItem(at: from, to: to)
            }
        } catch let exception {
            print(exception.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func url(for filename: String) -> URL {
        directory.appendingPathComponent(filename)
    }
    
    private var readIDs: Set<String> {
        Set(defaults.stringArray(forKey: Self.readIDsKey) ?? [])
    }
}

private struct ExtensionCrashDump: Codable {
    struct Reason: Codable {
        let exception: Int32
        let codes: [UInt64]
    }
    struct BinaryImage: Codable {
        let path: String
        let uuid: String?
        let baseAddress: String
        let size: UInt64
    }
    let capturedAt: Double
    let reason: Reason
    let binaryImages: [BinaryImage]
    let corpsePort: UInt32
    let osVersion: String
    let deviceType: String
    let architecture: String
    let appVersion: String
}
