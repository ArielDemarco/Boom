//
//  MetricKitManaging.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Observation

protocol MetricKitManaging: AnyObject, Observable, Sendable {
    @MainActor var summaries: [CrashReportSummary] { get }
    @MainActor func delete(_ summary: CrashReportSummary)
    @MainActor func deleteAll()
    func loadPayload(for summary: CrashReportSummary) async -> CrashPayload?
    @MainActor func markAsRead(_ summary: CrashReportSummary)
}
