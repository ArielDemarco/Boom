//
//  CrashRepository.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)
import Foundation

final class CrashRepository: @unchecked Sendable {
    private let fileManager: FileManager
    private let defaults: UserDefaults
    private let directory: URL
    private let encoder: JSONEncoder = .init()
    private let decoder: JSONDecoder = .init()

    private static let readIDsKey = "boom.readCrashIDs"

    init(
        fileManager: FileManager = .default,
        defaults: UserDefaults = .init(suiteName: "com.ademarco.bombapp.crashes") ?? .standard
    ) {
        self.fileManager = fileManager
        self.defaults = defaults

        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = support.appendingPathComponent("BoomApp/crashes", isDirectory: true)
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

    func loadPayload(for summary: CrashReportSummary) -> CrashReportPayload? {
        do {
            let data = try Data(contentsOf: url(for: summary.filename))
            return try decoder.decode(CrashReportPayload.self, from: data)
        } catch let exception {
            print(exception.localizedDescription)
            return nil
        }
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

    // MARK: - Private

    private func url(for filename: String) -> URL {
        directory.appendingPathComponent(filename)
    }

    private var readIDs: Set<String> {
        Set(defaults.stringArray(forKey: Self.readIDsKey) ?? [])
    }
}
#endif
