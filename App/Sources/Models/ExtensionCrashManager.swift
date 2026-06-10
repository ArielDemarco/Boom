//
//  ExtensionCrashManager.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(macOS)
import Observation

@Observable
@MainActor
final class ExtensionCrashManager: MetricKitManaging, @unchecked Sendable {
    private(set) var summaries: [CrashReportSummary] = []
    private let repository: CrashRepository

    init(repository: CrashRepository = CrashRepository()) {
        self.repository = repository
        Task {
            let loaded = await Task.detached(priority: .utility) {
                repository.importExtensionReports()
                return repository.loadSummaries()
            }.value
            self.summaries = loaded
        }
    }

    func delete(_ summary: CrashReportSummary) {
        summaries.removeAll { $0.id == summary.id }
        let repo = repository
        Task.detached(priority: .utility) { repo.delete(summary) }
    }

    func deleteAll() {
        let snapshot = summaries
        summaries.removeAll()
        let repo = repository
        Task.detached(priority: .utility) { repo.deleteAll(snapshot) }
    }

    func loadPayload(for summary: CrashReportSummary) async -> CrashPayload? {
        let repo = repository
        return await Task.detached(priority: .userInitiated) {
            repo.loadPayload(for: summary)
        }.value
    }

    func markAsRead(_ summary: CrashReportSummary) {
        guard let index = summaries.firstIndex(where: { $0.id == summary.id }),
              !summaries[index].isRead else { return }
        summaries[index].isRead = true
        let repo = repository
        let id = summary.id
        Task.detached(priority: .utility) { repo.markRead(id) }
    }

    func reload() async {
        let repo = repository
        let loaded = await Task.detached(priority: .utility) {
            repo.importExtensionReports()
            return repo.loadSummaries()
        }.value
        summaries = loaded
    }
}
#endif
