//
//  CrashReportsView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CrashReportDetailView: View {
    @Environment(\.metricKitManager) private var manager: any MetricKitManaging
    @Environment(\.dismiss) private var dismiss
    @State private var state: CrashReportLoadState = .loading
    
    let summary: CrashReportSummary
    

    var body: some View {
        NavigationStack {
            Group {
                switch state {
                case .loading:
                    ProgressView("Loading report…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded(.structured(let payload)):
                    PayloadView(summary: summary, payload: payload)

                case .loaded(.dump(let json)):
                    CrashDumpView(json: json)

                case .failed:
                    ContentUnavailableView(
                        "Failed to load",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The crash report file could not be read.")
                    )
                }
            }
            .navigationTitle("Crash Detail")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            guard let payload = await manager.loadPayload(for: summary) else {
                state = .failed
                return
            }
            state = .loaded(payload)
        }
    }
}

#Preview {
    CrashReportDetailView(
        summary: .init(
            id: UUID(),
            date: .now,
            signal: 8,
            exceptionType: 10,
            isRead: false
        )
    )
}
