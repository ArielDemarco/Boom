//
//  MetricKitManager.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)
import MetricKit
import Observation

@Observable
@MainActor
final class MetricKitManager: NSObject, MetricKitManaging {
    private(set) var summaries: [CrashReportSummary]
    private let repository: CrashRepository

    init(
        repository: CrashRepository = CrashRepository(),
        summaries: [CrashReportSummary] = []
    ) {
        self.repository = repository
        self.summaries = summaries
        super.init()
        MXMetricManager.shared.add(self)
        CrashContextRegistry.register()
        CrashContextRegistry.update(sessionId: UUID())
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
        Task.detached(priority: .utility) {
            repo.delete(summary)
        }
    }

    func deleteAll() {
        let snapshot = summaries
        summaries.removeAll()
        let repo = repository
        Task.detached(priority: .utility) {
            repo.deleteAll(snapshot)
        }
    }

    nonisolated func loadPayload(for summary: CrashReportSummary) async -> CrashPayload? {
        let repo = await MainActor.run { repository }
        return repo.loadPayload(for: summary)
    }

    func markAsRead(_ summary: CrashReportSummary) {
        guard let index = summaries.firstIndex(where: { $0.id == summary.id }),
              !summaries[index].isRead else { return }
        summaries[index].isRead = true
        let repo = repository
        let id = summary.id
        Task.detached(priority: .utility) {
            repo.markRead(id)
        }
    }
}

// MARK: - MXMetricManagerSubscriber

extension MetricKitManager: MXMetricManagerSubscriber {
    nonisolated func didReceive(_ payloads: [MXMetricPayload]) {}

    nonisolated func didReceive(_ payloads: [MXDiagnosticPayload]) {
        var newSummaries: [CrashReportSummary] = []

        for payload in payloads {
            for diagnostic in payload.crashDiagnostics ?? [] {
                let id = UUID()
                let summary = CrashReportSummary(
                    id: id,
                    date: payload.timeStampEnd,
                    signal: diagnostic.signal?.intValue,
                    exceptionType: diagnostic.exceptionType?.intValue,
                    isRead: false,
                    source: .metricKit
                )
                let fullPayload = CrashReportPayload(
                    sessionStart: payload.timeStampBegin,
                    sessionEnd: payload.timeStampEnd,
                    applicationVersion: diagnostic.applicationVersion,
                    signal: diagnostic.signal?.intValue,
                    exceptionType: diagnostic.exceptionType?.intValue,
                    exceptionCode: diagnostic.exceptionCode?.intValue,
                    virtualMemoryRegionInfo: diagnostic.virtualMemoryRegionInfo,
                    terminationReason: diagnostic.terminationReason,
                    osVersion: diagnostic.metaData.osVersion,
                    deviceType: diagnostic.metaData.deviceType,
                    platformArchitecture: diagnostic.metaData.platformArchitecture,
                    callStackJSON: String(
                        data: diagnostic.callStackTree.jsonRepresentation(),
                        encoding: .utf8
                    ) ?? ""
                )
                repository.save(payload: fullPayload, filename: summary.filename)
                newSummaries.append(summary)
            }
        }

        Task { @MainActor in
            self.summaries.insert(contentsOf: newSummaries, at: 0)
        }
    }
}
#endif
