//
//  CrashReportsView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CrashReportsView: View {
    @Environment(\.metricKitManager) private var manager: any MetricKitManaging
    @State private var selected: CrashReportSummary?

    var body: some View {
        Group {
            if manager.summaries.isEmpty {
                ScrollView {
                    ContentUnavailableView(
                        "No crash reports",
                        systemImage: "checkmark.shield",
                        description: Text("Reports are captured by the crash extension and imported on launch. Pull to check for new ones.")
                    )
                }
            } else {
                List {
                    ForEach(manager.summaries) { summary in
                        CrashReportRow(summary: summary)
                            .onTapGesture {
                                manager.markAsRead(summary)
                                selected = summary
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.map { manager.summaries[$0] }.forEach { manager.delete($0) }
                    }
                }
            }
        }
        .navigationTitle("Crash Reports")
        .toolbar {
            if !manager.summaries.isEmpty {
                ToolbarItem(placement: .automatic) {
                    Button("Clear all", role: .destructive) {
                        manager.deleteAll()
                    }
                }
            }
        }
        .sheet(item: $selected) { summary in
            CrashReportDetailView(summary: summary)
        }
    }
}

#Preview {
    CrashReportsView()
}
