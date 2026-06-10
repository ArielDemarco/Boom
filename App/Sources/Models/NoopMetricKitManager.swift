//
//  NoopMetricKitManager.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Observation

@Observable
final class NoopMetricKitManager: MetricKitManaging, @unchecked Sendable {
    nonisolated init() {}

    @MainActor private(set) var summaries: [CrashReportSummary] = []
    @MainActor func delete(_ summary: CrashReportSummary) {}
    @MainActor func deleteAll() {}
    func loadPayload(for summary: CrashReportSummary) async -> CrashPayload? { nil }
    @MainActor func markAsRead(_ summary: CrashReportSummary) {}
    @MainActor func reload() async {}
}
